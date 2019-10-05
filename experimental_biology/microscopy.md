# Microscopy

## Definitions

dichromatic beamsplitter (dichroic mirror): "An interference filter/mirror combination commonly used in fluorescence microscopy filter sets to produce a sharply defined transition between transmitted and reflected wavelengths. When inclined at a 45° angle with respect to the incident illumination and emission light beams, the dichromatic mirror usually reflects short excitation wavelengths through a 90° angle onto the specimen and transmits longer emitted fluorescence wavelengths straight through to the eyepieces and detector system... The dichromatic mirror is usually the central element of three filters (excitation, barrier, and dichromatic mirror) contained within a fluorescence filter optical block." (Murphy)

epi-illumination: "the illuminator is placed on the same side of the specimen as the objective, and the objective performs a dual role as both a condenser and an objective. A dichromatic mirror is placed in the light path to reflect excitatory light from the lamp toward the specimen and transmit emitted fluorescent wavelengths to the eye or camera." (Murphy)

transillumination: "the light source and objective are on opposite sides of the specimen so that illuminating beams pass through the specimen" (Murphy)

## Equations

Variables
- $D$: lens diameter or aperture
- $f$: lens focal length
- $\lambda$: wavelength
- $n$: refractive index of medium between the objective lens and the specimen (air: $n = 1$; oil: $n = 1.515$)

**Spatial resolution ($d$)**: minimum spot size radius to which a lens can focus light (see Knight section 24.5)
$$d = \frac{1.22 \lambda f}{D} = \frac{1.22 \lambda}{2 \mathrm{NA}}$$

**Angular resolution ($\theta_\mathrm{min}$)**
$$\theta_\mathrm{min} = \frac{1.22 \lambda}{D}$$
- Rayleigh's criterion: two objects with angular separation $\alpha$ are marginally resolvable if $\alpha = \theta_\mathrm{min}$.
  - angular separation: angle between 2 objects as seen from the lens (Knight Figure 24.18)

**Angular aperture ($a$)**: the angular size of the lens aperture as seen from the focal point ([Wikipedia](https://en.wikipedia.org/wiki/Angular_aperture))
$$a = 2 \tan^{-1} \frac{D/2}{f}$$

**Numerical aperture ($\mathrm{NA}$)**
$$\mathrm{NA} = n \sin \theta$$
where $\theta = a/2$ is the half angle of the cone of specimen light accepted by the objective

**Brightness ($B$)**
$$B \propto \begin{cases}
\frac{\mathrm{NA}^2}{M^2}, & \mathrm{trans-illumination} \\
\frac{\mathrm{NA}^4}{M^2}, & \mathrm{epi-illumination}
\end{cases}$$

**Depth of field ($\mathrm{DOF}$)**
$$\mathrm{DOF} = \frac{n\lambda}{\mathrm{NA}^2}$$
(Murphy)

## Kohler illumination

## Rules of thumb

"To make optimal use of the resolution afforded by the objective, an overall magnification equal to 500–1000 times the NA of the objective is required." (Murphy)

"A useful guideline for beginners is to stop down the condenser aperture to about 70% of the maximum aperture diameter, but this is not a rigid rule." (Murphy)

## Questions

1. How does a glass cover slip affect image quality? What if the sample is not amenable to mounting with a cover slip?

2. Consider a microscope set up with Koehler illumination (e.g., Fig. 1.6 in *Fundamentals of Light Microscopy and Electronic Imaging*). Then, per Fig. 1.5, both field planes (in focus, relative to the viewer) and aperture planes (out of focus) are projected onto the retina. Why, then, does the viewer perceive the object to be in focus?

3. Exactly what is Abbé's theory trying to say? "Abbé demonstrated that at least two different orders of light must be captured by a lens for interference to occur in the image plane" (Murphy). What does it mean in Figure 5.15a that no image is formed?

4. Why is resolving power defined as $d = \frac{0.61 \lambda}{\mathrm{NA}}$?

$$\frac{f}{D} = \frac{1}{2 \mathrm{NA}} = \frac{1}{2n \sin \theta}$$
$$\sin\theta = \frac{D}{2nf}$$

5. How to relate the depth of field formula by Murphy with the depth of field formula given by Wikipedia / Marc Levoy?

$$\mathrm{DOF} = \frac{n\lambda}{\mathrm{NA}^2} = \frac{2U^2NC}{f^2}$$

6. Why is there a tradeoff between spatial resolution and contrast (Murphy, Chapter 6)?

## References

Spencer, Michael. Fundamentals of light microscopy. Vol. 6. CUP Archive, 1982.

Pluta, Maksymilian, and Pluta Maksymilian. Advanced light microscopy. Vol. 1. Amsterdam: Elsevier, 1988.

Murphy, Douglas B. Fundamentals of light microscopy and electronic imaging. Wiley‐Blackwell, 2012.

### Tools / Tutorials

[Analyzing fluorescence microscopy images with ImageJ](https://petebankhead.gitbooks.io/imagej-intro/content/)

[Open Microscopy Environment](https://www.openmicroscopy.org/)