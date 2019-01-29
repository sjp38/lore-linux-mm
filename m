Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 244CEC169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 19:56:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CD3F32084C
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 19:56:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="m5NKlV/d"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CD3F32084C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 80E148E0005; Tue, 29 Jan 2019 14:56:53 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7BBBF8E0002; Tue, 29 Jan 2019 14:56:53 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6AB088E0005; Tue, 29 Jan 2019 14:56:53 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0B02E8E0002
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 14:56:53 -0500 (EST)
Received: by mail-wm1-f69.google.com with SMTP id a11so6235852wmh.2
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 11:56:52 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=DbE1GrRmgpsPkMb62kQRgfWSg0dLU9+SDcD6byWUaX4=;
        b=dYjsO6zJ8sEIXwQs/r4rTFKjnNYyZkSln4K6rVhVubyQ09Upm8pTyxL1aHat0Rod1P
         8aiZbg//F9uZX9AOI5CvY1foiwEUeMKEckbFslhWgRl5rRA2L3eH/GHcnVsUCAQkJMv/
         0IhC1lfzUuqoQy0XR5/EnLFtVmiodN2Pog8S41lq25hsBJ272eFSSPpEMVvKqY2moJeB
         CB+aG8qnEMTHDsmjvpiKyBGMMXwvvxLYhEdsVAglKALHVuoVO+DL4ihgfdVEGSRIRHXr
         IXHM8qusMPr0GcI6Hei9Z+FcS13gYSmIXyBvOif4qjwnzlTE7OGFxeTZgfSLcZuzY0w5
         7IpQ==
X-Gm-Message-State: AJcUukdriCfNWTx4DiufqJ2p/rWWJ+oKNL2KnoDIGFodS3au1rSGgRbZ
	jQE1Z7ZDgDvyiyKTQup5H5xf/CFL/jC1mKVJq36teZpR0jYau1YXAJMhxcn3CpNj8EPSkPONlIK
	eIxybM0HRN7d14jjSqCC5ngokMdGQPAWis8/OY2EIVotGPlt4ypiZ5NE8EXnmFtR05aN6kIrqQU
	OlFQE05MvXCWmIWJ9uFDQ+tN7anaS57mQFjhrTIsI7kVV4BL+zgVTy79woFQVsEtE4JesvvvZJB
	CBvqrhMyRdQ/nUQ7H2GQVYi8KlBJy9w5XTUzx1CfYLVOj+3ehSquneiE+dqc2n0k270q4pwCb9r
	IsXL1kgrLM/PtRZlwl/hR//Z/zMz99Kfc7SK+QVkKAgBVCqp0yPHOI3zJx8qOy43B1bMX+00EkS
	D
X-Received: by 2002:adf:9467:: with SMTP id 94mr26759084wrq.305.1548791812550;
        Tue, 29 Jan 2019 11:56:52 -0800 (PST)
X-Received: by 2002:adf:9467:: with SMTP id 94mr26759045wrq.305.1548791811719;
        Tue, 29 Jan 2019 11:56:51 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548791811; cv=none;
        d=google.com; s=arc-20160816;
        b=0cSfpnp+GITuhhlPaV8nD0KPwYT829iPN8vxhIvLrMIC3vrpfIvv9kKFDAbnOT7o9U
         fZKoRqsBgT4fOCIHPFiy51yiSDnHpd/uj7wn6IxK033d9CeY48GY1X7sxgX/9yRe+vjw
         WB6njceZRHt0hSNbs7P2cNa1Ryf/jpna+UPlOhGglfll+BPk0rGWm3oUOQFjXDOF6QXb
         nRDFQycB7NW5dcNTq/A9Nof5vAP6doHd6Za8FQmuzDYH17P3Q7XfuJxStqUpgK2yPLHO
         bkv1uY9landbFnzsRFAqghmQdyg7fwNqJB5n1qtUp0aQBJ/7Q6Vuf+oQrWZkbKWiN0uc
         NwJA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=DbE1GrRmgpsPkMb62kQRgfWSg0dLU9+SDcD6byWUaX4=;
        b=kUNnSX58BM/IaleYXi2k5Yx8mkKZLjjYgm4DnL/bh/tmkqIXM56m4GpufpBdMlvMd9
         5Nw6VTx8WRAYFHZTKD1jjTeOZ+1J+LVKbU7jQYnnNAbhZ9IcCZvFq1NaA8/LfCk1cM5D
         opBtuii78L66opxJX12THv0TaS97sd85S5noiAGobvx+PhjNv4ORFz/DvAQyVktqQGi/
         kPyA1L2WJO5HqNoE53oFPxEQOIh4U9noGVZiFLkBaGwo7MNSrqc1VBR1N7k379EZePVk
         oUA7nFXkaieKsBBKRoYCbnwLu3cd4wAFryrpI4th397XCBAQGxmRBq6uUxToe3xm2hbW
         04xw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="m5NKlV/d";
       spf=pass (google.com: domain of alexdeucher@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexdeucher@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n188sor2563761wmn.17.2019.01.29.11.56.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 29 Jan 2019 11:56:51 -0800 (PST)
Received-SPF: pass (google.com: domain of alexdeucher@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="m5NKlV/d";
       spf=pass (google.com: domain of alexdeucher@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexdeucher@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=DbE1GrRmgpsPkMb62kQRgfWSg0dLU9+SDcD6byWUaX4=;
        b=m5NKlV/dlJdtECUzkiGCYY9gRyekiXv+dVEOYxQq18wuAaE3Om/1m+T04tVbdZQwod
         fyQxO6w+Fvpcp1gDkG/ee+h/mMu9zmZU8uEpucCEKMBVZWkRd+QYu28jAUmL94H9xpVd
         zFuL9ORWYfV9HxA81s3uQigQw1RkT3960FlX30SQOtSJPesSr8de9IJHqeWTYWUFhQwi
         Eo6liZ4HFhKSDXZOkGF2n1nF/IuoU+czgnAUWbkvgDZ0KYVumZDidPEpBl5KViJQ+dM+
         X2jDfIF4A1h6ZQQF2z0oLs/KQ33CoIJqDHDxopqg5CCtmRNacwtQYK4fUyuyd930nyVQ
         S5tw==
X-Google-Smtp-Source: ALg8bN5FtxNkNjW599qrUzEnetIRTAX187hhjUN5bTMbybWCmuHZS8mhBUhWb+uBJPDX1krcjBMM/76FizLN9vWBbTg=
X-Received: by 2002:a7b:c8d7:: with SMTP id f23mr22060809wml.121.1548791811117;
 Tue, 29 Jan 2019 11:56:51 -0800 (PST)
MIME-Version: 1.0
References: <20190129174728.6430-1-jglisse@redhat.com> <20190129174728.6430-2-jglisse@redhat.com>
In-Reply-To: <20190129174728.6430-2-jglisse@redhat.com>
From: Alex Deucher <alexdeucher@gmail.com>
Date: Tue, 29 Jan 2019 14:56:38 -0500
Message-ID: <CADnq5_N8QLA_80j+iCtMHvSZhc-WFpzdZhpk6jR9yhoNoUDFZA@mail.gmail.com>
Subject: Re: [RFC PATCH 1/5] pci/p2p: add a function to test peer to peer capability
To: Jerome Glisse <jglisse@redhat.com>
Cc: linux-mm <linux-mm@kvack.org>, Joerg Roedel <jroedel@suse.de>, 
	"Rafael J . Wysocki" <rafael@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, 
	Felix Kuehling <Felix.Kuehling@amd.com>, LKML <linux-kernel@vger.kernel.org>, 
	Maling list - DRI developers <dri-devel@lists.freedesktop.org>, Christoph Hellwig <hch@lst.de>, 
	iommu@lists.linux-foundation.org, Jason Gunthorpe <jgg@mellanox.com>, 
	Linux PCI <linux-pci@vger.kernel.org>, Bjorn Helgaas <bhelgaas@google.com>, 
	Robin Murphy <robin.murphy@arm.com>, Logan Gunthorpe <logang@deltatee.com>, 
	Christian Koenig <christian.koenig@amd.com>, Marek Szyprowski <m.szyprowski@samsung.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 29, 2019 at 12:47 PM <jglisse@redhat.com> wrote:
>
> From: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
>
> device_test_p2p() return true if two devices can peer to peer to
> each other. We add a generic function as different inter-connect
> can support peer to peer and we want to genericaly test this no
> matter what the inter-connect might be. However this version only
> support PCIE for now.
>

What about something like these patches:
https://cgit.freedesktop.org/~deathsimple/linux/commit/?h=3Dp2p&id=3D4fab9f=
f69cb968183f717551441b475fabce6c1c
https://cgit.freedesktop.org/~deathsimple/linux/commit/?h=3Dp2p&id=3Df90b12=
d41c277335d08c9dab62433f27c0fadbe5
They are a bit more thorough.

Alex

> Signed-off-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> Cc: Logan Gunthorpe <logang@deltatee.com>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: Rafael J. Wysocki <rafael@kernel.org>
> Cc: Bjorn Helgaas <bhelgaas@google.com>
> Cc: Christian Koenig <christian.koenig@amd.com>
> Cc: Felix Kuehling <Felix.Kuehling@amd.com>
> Cc: Jason Gunthorpe <jgg@mellanox.com>
> Cc: linux-kernel@vger.kernel.org
> Cc: linux-pci@vger.kernel.org
> Cc: dri-devel@lists.freedesktop.org
> Cc: Christoph Hellwig <hch@lst.de>
> Cc: Marek Szyprowski <m.szyprowski@samsung.com>
> Cc: Robin Murphy <robin.murphy@arm.com>
> Cc: Joerg Roedel <jroedel@suse.de>
> Cc: iommu@lists.linux-foundation.org
> ---
>  drivers/pci/p2pdma.c       | 27 +++++++++++++++++++++++++++
>  include/linux/pci-p2pdma.h |  6 ++++++
>  2 files changed, 33 insertions(+)
>
> diff --git a/drivers/pci/p2pdma.c b/drivers/pci/p2pdma.c
> index c52298d76e64..620ac60babb5 100644
> --- a/drivers/pci/p2pdma.c
> +++ b/drivers/pci/p2pdma.c
> @@ -797,3 +797,30 @@ ssize_t pci_p2pdma_enable_show(char *page, struct pc=
i_dev *p2p_dev,
>         return sprintf(page, "%s\n", pci_name(p2p_dev));
>  }
>  EXPORT_SYMBOL_GPL(pci_p2pdma_enable_show);
> +
> +bool pci_test_p2p(struct device *devA, struct device *devB)
> +{
> +       struct pci_dev *pciA, *pciB;
> +       bool ret;
> +       int tmp;
> +
> +       /*
> +        * For now we only support PCIE peer to peer but other inter-conn=
ect
> +        * can be added.
> +        */
> +       pciA =3D find_parent_pci_dev(devA);
> +       pciB =3D find_parent_pci_dev(devB);
> +       if (pciA =3D=3D NULL || pciB =3D=3D NULL) {
> +               ret =3D false;
> +               goto out;
> +       }
> +
> +       tmp =3D upstream_bridge_distance(pciA, pciB, NULL);
> +       ret =3D tmp < 0 ? false : true;
> +
> +out:
> +       pci_dev_put(pciB);
> +       pci_dev_put(pciA);
> +       return false;
> +}
> +EXPORT_SYMBOL_GPL(pci_test_p2p);
> diff --git a/include/linux/pci-p2pdma.h b/include/linux/pci-p2pdma.h
> index bca9bc3e5be7..7671cc499a08 100644
> --- a/include/linux/pci-p2pdma.h
> +++ b/include/linux/pci-p2pdma.h
> @@ -36,6 +36,7 @@ int pci_p2pdma_enable_store(const char *page, struct pc=
i_dev **p2p_dev,
>                             bool *use_p2pdma);
>  ssize_t pci_p2pdma_enable_show(char *page, struct pci_dev *p2p_dev,
>                                bool use_p2pdma);
> +bool pci_test_p2p(struct device *devA, struct device *devB);
>  #else /* CONFIG_PCI_P2PDMA */
>  static inline int pci_p2pdma_add_resource(struct pci_dev *pdev, int bar,
>                 size_t size, u64 offset)
> @@ -97,6 +98,11 @@ static inline ssize_t pci_p2pdma_enable_show(char *pag=
e,
>  {
>         return sprintf(page, "none\n");
>  }
> +
> +static inline bool pci_test_p2p(struct device *devA, struct device *devB=
)
> +{
> +       return false;
> +}
>  #endif /* CONFIG_PCI_P2PDMA */
>
>
> --
> 2.17.2
>
> _______________________________________________
> dri-devel mailing list
> dri-devel@lists.freedesktop.org
> https://lists.freedesktop.org/mailman/listinfo/dri-devel

