Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 129316B002B
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 18:54:27 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fa10so7238226pad.14
        for <linux-mm@kvack.org>; Tue, 16 Oct 2012 15:54:26 -0700 (PDT)
References: <CAAQKjZMYFNMEnb2ue2aR+6AEbOixnQFyggbXrThBCW5VOznePg@mail.gmail.com> <20121016090434.7d5e088152a3e0b0606903c8@nvidia.com> <CAAQKjZNQFfxpr-7dFb4cgNB2Gkrxxrswds_fSrYgssxXaqRF7g@mail.gmail.com> <20121016.171338.1300372057637804407.hdoyu@nvidia.com>
In-Reply-To: <20121016.171338.1300372057637804407.hdoyu@nvidia.com>
Mime-Version: 1.0 (1.0)
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=euc-kr
Message-Id: <A52B7C89-16F2-44A0-A9FF-2EB599F4F074@gmail.com>
From: Inki Dae <daeinki@gmail.com>
Subject: Re: [Linaro-mm-sig] [RFC 0/2] DMA-mapping & IOMMU - physically contiguous allocations
Date: Wed, 17 Oct 2012 07:54:17 +0900
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hiroshi Doyu <hdoyu@nvidia.com>
Cc: "inki.dae@samsung.com" <inki.dae@samsung.com>, "m.szyprowski@samsung.com" <m.szyprowski@samsung.com>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>, "arnd@arndb.de" <arnd@arndb.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kyungmin.park@samsung.com" <kyungmin.park@samsung.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-tegra@vger.kernel.org" <linux-tegra@vger.kernel.org>

Hi Hiroshi,



2012. 10. 16. =BF=C0=C8=C4 11:13 Hiroshi Doyu <hdoyu@nvidia.com> =C0=DB=BC=BA=
:

> Hi Inki,
>=20
> Inki Dae <inki.dae@samsung.com> wrote @ Tue, 16 Oct 2012 12:12:49 +0200:
>=20
>> Hi Hiroshi,
>>=20
>> 2012/10/16 Hiroshi Doyu <hdoyu@nvidia.com>:
>>> Hi Inki/Marek,
>>>=20
>>> On Tue, 16 Oct 2012 02:50:16 +0200
>>> Inki Dae <inki.dae@samsung.com> wrote:
>>>=20
>>>> 2012/10/15 Marek Szyprowski <m.szyprowski@samsung.com>:
>>>>> Hello,
>>>>>=20
>>>>> Some devices, which have IOMMU, for some use cases might require to
>>>>> allocate a buffers for DMA which is contiguous in physical memory. Suc=
h
>>>>> use cases appears for example in DRM subsystem when one wants to impro=
ve
>>>>> performance or use secure buffer protection.
>>>>>=20
>>>>> I would like to ask if adding a new attribute, as proposed in this RFC=

>>>>> is a good idea? I feel that it might be an attribute just for a single=

>>>>> driver, but I would like to know your opinion. Should we look for othe=
r
>>>>> solution?
>>>>>=20
>>>>=20
>>>> In addition, currently we have worked dma-mapping-based iommu support
>>>> for exynos drm driver with this patch set so this patch set has been
>>>> tested with iommu enabled exynos drm driver and worked fine. actually,
>>>> this feature is needed for secure mode such as TrustZone. in case of
>>>> Exynos SoC, memory region for secure mode should be physically
>>>> contiguous and also maybe OMAP but now dma-mapping framework doesn't
>>>> guarantee physically continuous memory allocation so this patch set
>>>> would make it possible.
>>>=20
>>> Agree that the contigous memory allocation is necessary for us too.
>>>=20
>>> In addition to those contiguous/discontiguous page allocation, is
>>> there any way to _import_ anonymous pages allocated by a process to be
>>> used in dma-mapping API later?
>>>=20
>>> I'm considering the following scenario, an user process allocates a
>>> buffer by malloc() in advance, and then it asks some driver to convert
>>> that buffer into IOMMU'able/DMA'able ones later. In this case, pages
>>> are discouguous and even they may not be yet allocated at
>>> malloc()/mmap().
>>>=20
>>=20
>> I'm not sure I understand what you mean but we had already tried this
>> way and for this, you can refer to below link,
>>               http://www.mail-archive.com/dri-devel@lists.freedesktop.org=
/msg22555.html
>=20
> The above patch doesn't seem to have so much platform/SoC specific
> code but rather it could common over other SoC as well. Is there any
> plan to make it more generic, which can be used by other DRM drivers?
>=20

Right, the above patch has no any platform/SoC specific code but doesn't use=
 dma-mapping API . Anyway we should refrain from using such thing because ge=
m object could still be used and shared with other processes even if user pr=
ocess freed user region allocated by malloc()

And our new patch in progress would resolve this issue and this way is simil=
ar to drm-based via driver of mainline kernel. And this patch isn't consider=
ed for common use and is specific to platform/SoC so much. The pages backed c=
an be used only by 2d gpu's dma.

Thanks,
Inki Dae

> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
