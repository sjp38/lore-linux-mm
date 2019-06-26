Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 827DAC48BD3
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 16:42:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1B26320644
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 16:42:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="sRFIhXyw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1B26320644
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8EBD68E0003; Wed, 26 Jun 2019 12:42:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 89E1F8E0002; Wed, 26 Jun 2019 12:42:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 78C828E0003; Wed, 26 Jun 2019 12:42:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f198.google.com (mail-vk1-f198.google.com [209.85.221.198])
	by kanga.kvack.org (Postfix) with ESMTP id 552EF8E0002
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 12:42:55 -0400 (EDT)
Received: by mail-vk1-f198.google.com with SMTP id a4so1077367vki.23
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 09:42:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to;
        bh=XiZ2kvA4jyR/va4UmVyGQlU0d2wFBUuuiuraanZnnLk=;
        b=KVeNOnJjjHns52RvaeUrKtamdZApaRbEe8xS2X6C3veRbI3ogVBl1NCuceT52WE56I
         KodDlWYRqAx/H4dWth6/iWR/x4NmlQ+oCAriQK+sRktSv7av5u2y+BzWFgL+wqaf0H5J
         foZ5vI6+FXv5b3y4T4w8xuPK03PI7DS5qmVzlDbHQv51Q1cm0lMC9Y+iCCHWIutdp4QZ
         dIwq2+0uCldP2p5bFbOPCXJkHYtaiySyFVPJGDlN59RGXxHf8R6So3GafYs0S1Dypdbf
         ryDnARandAZB3ByV4WxsMjodLcVXxxZzhRvRQTe0CyGfmTlHklZjEPoVZcpDxGEWw2ps
         7JSw==
X-Gm-Message-State: APjAAAWmPuxD/XeLzBKhMcv0wzTEVyAs6c9tYaXmawfhn4CngDMW668C
	RX4yib1G/Vxg/QT7j5HA6rW8jjjENBBWL6oYRFGKlx5m9k+LzfVb07L/hV2vNi2M7leaROOKFkR
	ebhxPLT6wkBp4bg7xhzCYLkbt9lXyfMclOV9ASyfweuui60AF62sBpuGy1ovr0t99iQ==
X-Received: by 2002:a67:c016:: with SMTP id v22mr3827968vsi.107.1561567375133;
        Wed, 26 Jun 2019 09:42:55 -0700 (PDT)
X-Received: by 2002:a67:c016:: with SMTP id v22mr3827945vsi.107.1561567374691;
        Wed, 26 Jun 2019 09:42:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561567374; cv=none;
        d=google.com; s=arc-20160816;
        b=Gtmyc9jKlRbYZ9EU5V0TIPhBZq/JBAsTCwA3soOKVOk0EHIbrMstvt1EjpDwuz4m73
         x36LuJth7xrp0uLWqVze551WPYATVHIlXqM7m0DUsOzY99cMnEvpaJCC34WD4UWvXkj5
         heKo+RDsqvUVzC7h8hbZVQPvJf1/hm8ohsn6KQBqBb+TfUdTsujQHeMu6PJ9wUiaENXi
         brKipw8QjuxC+t4n0n9dkNd0bm+5oqp0BzyOYAKXnacU3MdJNIbFMmAV6HlKIieCrwcL
         G94IVZY/47obReQNa35Kee79wALhEyD8orATp+uosw57TLzWraf6xrkznR3ZJ3E5jros
         EhLw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:subject:message-id:date:from:in-reply-to:references:mime-version
         :dkim-signature;
        bh=XiZ2kvA4jyR/va4UmVyGQlU0d2wFBUuuiuraanZnnLk=;
        b=zhNgFk063bPEEMhZ02tWTQv+gOFQzwm4Ry85/J90fZ1Pr+mxC3odxFTLU7fiF8Vrfa
         ZpUxlKKdmZM8Vgbx/pUtHR1ROb6t3srW1FwSGs8kUjPU680g5lASIKMUFe6AEemZvKXc
         4jHnzTG+/KUjUGaqAj9YGSEIjfBiN+UBR/eM+YdMa3CCtOo0gpbzhpjecfLF+huS2B6L
         RGNFyJKnFkW11g1Hc7qGSv9wGbO8d2PtPhOf7WmVS1Mv8gP6AqCW+cTFSdLyA5cy5Rwd
         Sb6WMlPAmgz/1yZ9AJu13tlw3Syu02KM6fRv+dq9ZgkBU2zafTg3aVhPC17Fdb+v9AZ+
         LuHg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=sRFIhXyw;
       spf=pass (google.com: domain of pankajssuryawanshi@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=pankajssuryawanshi@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id u21sor9410964uap.43.2019.06.26.09.42.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 26 Jun 2019 09:42:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of pankajssuryawanshi@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=sRFIhXyw;
       spf=pass (google.com: domain of pankajssuryawanshi@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=pankajssuryawanshi@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to;
        bh=XiZ2kvA4jyR/va4UmVyGQlU0d2wFBUuuiuraanZnnLk=;
        b=sRFIhXywufBO++TS+ryB1SmYWeVHv+bTFFcIRILUHDOzvGeatbkNkj46qdVrdrvRyM
         7d5dP8QgB5qcExwwjS/OVDzo9hE6jn0lXPUJ3/3yK+X5zJyhD0qAhG+jLguybKffozzY
         mNbsBnG4r+z8JQbo0YEyQ0tkwrXpUdB4VPwZKIU6/g7lklauN29RDDXgzMOJVFCawAwV
         fBwXUsEBRyydcv0GVUTz4LJoMzPm1ZLk7zftxYnq4CC3RgxVbq8HydWG2Jd8DrqUyaXc
         VCXezd6bXVw016E7zPODVX+GS1D9nSvhyTKNw2Kje1cD2I/z5EplWIqicwedgaSTQqFX
         yHDQ==
X-Google-Smtp-Source: APXvYqwcTa3UDAPlUPBUMrH/Y1/nc1WfDoELbdgtmLpz6OTDpqqll6ddgRZ8HLMzaiqPayI6LrkNV1VDhmlf6TReO80=
X-Received: by 2002:ab0:7848:: with SMTP id y8mr3228942uaq.58.1561567374300;
 Wed, 26 Jun 2019 09:42:54 -0700 (PDT)
MIME-Version: 1.0
References: <CACDBo564RoWpi8y2pOxoddnn0s3f3sA-fmNxpiXuxebV5TFBJA@mail.gmail.com>
In-Reply-To: <CACDBo564RoWpi8y2pOxoddnn0s3f3sA-fmNxpiXuxebV5TFBJA@mail.gmail.com>
From: Pankaj Suryawanshi <pankajssuryawanshi@gmail.com>
Date: Wed, 26 Jun 2019 22:12:45 +0530
Message-ID: <CACDBo55GfomD4yAJ1qaOvdm8EQaD-28=etsRHb39goh+5VAeqw@mail.gmail.com>
Subject: Re: DMA-API attr - DMA_ATTR_NO_KERNEL_MAPPING
To: linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, linux-kernel@vger.kernel.org, 
	Vlastimil Babka <vbabka@suse.cz>
Content-Type: multipart/alternative; boundary="000000000000a35b65058c3cbc65"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--000000000000a35b65058c3cbc65
Content-Type: text/plain; charset="UTF-8"

[CC: linux kernel and Vlastimil Babka]

On Wed, Jun 26, 2019 at 10:11 PM Pankaj Suryawanshi <
pankajssuryawanshi@gmail.com> wrote:

> Hello,
>
> I am writing driver in which I used DMA_ATTR_NO_KERNEL_MAPPING attribute
> for cma allocation using dma_alloc_attr(), as per kernel docs
> https://www.kernel.org/doc/Documentation/DMA-attributes.txt  buffers
> allocated with this attribute can be only passed to user space by calling
> dma_mmap_attrs().
>
> how can I mapped in kernel space (after dma_alloc_attr with
> DMA_ATTR_NO_KERNEL_MAPPING ) ?
>
> For example.
>
> 1. virtual_addr = dma_alloc_attr(device, size,, phys, GFP_KERNEL,
> DMA_ATTR_NO_KERNEL_MAPPING );
> 2. Now i can use phys for driver as physical address and i am using in
> drivers, working fine.
> 3. Now i want to use virtual address in kernel space(in some cases virtual
> address required in my driver), not allow to use virtual_addr in kernel
> space because DMA_ATTR_NO_KERNEL_MAPPING, How can i mapped again to
> kernel space ?
>
> How can i used DMA_ATTR_NO_KERNEL_MAPPING  and mapped some area for
> kernel space when needed ?
>
> Is there any apis available ? or improvement is required in linux kernel
> dma-apis ?
>
> Regards,
> Pankaj
>

--000000000000a35b65058c3cbc65
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div>[CC: linux kernel and Vlastimil Babka]</div><br><div =
class=3D"gmail_quote"><div dir=3D"ltr" class=3D"gmail_attr">On Wed, Jun 26,=
 2019 at 10:11 PM Pankaj Suryawanshi &lt;<a href=3D"mailto:pankajssuryawans=
hi@gmail.com">pankajssuryawanshi@gmail.com</a>&gt; wrote:<br></div><blockqu=
ote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-left:1px=
 solid rgb(204,204,204);padding-left:1ex"><div dir=3D"ltr">Hello,<br><br>I =
am writing driver in which I used DMA_ATTR_NO_KERNEL_MAPPING attribute for =
cma allocation using dma_alloc_attr(), as per kernel docs=C2=A0<a href=3D"h=
ttps://www.kernel.org/doc/Documentation/DMA-attributes.txt" target=3D"_blan=
k">https://www.kernel.org/doc/Documentation/DMA-attributes.txt</a>=C2=A0 b<=
span style=3D"color:rgb(0,0,0);white-space:pre-wrap">uffers allocated with =
this attribute can be only passed to user space </span><span style=3D"color=
:rgb(0,0,0);white-space:pre-wrap">by calling dma_mmap_attrs().</span><div><=
br></div><div><font color=3D"#000000"><span style=3D"white-space:pre-wrap">=
how can I mapped in kernel space (after dma_alloc_attr with </span></font>D=
MA_ATTR_NO_KERNEL_MAPPING=C2=A0<span style=3D"white-space:pre-wrap;color:rg=
b(0,0,0)">) ?</span></div><div><font color=3D"#000000"><span style=3D"white=
-space:pre-wrap"><br></span></font></div><div><font color=3D"#000000"><span=
 style=3D"white-space:pre-wrap">For example.</span></font></div><div><font =
color=3D"#000000"><span style=3D"white-space:pre-wrap"><br></span></font></=
div><div><font color=3D"#000000"><span style=3D"white-space:pre-wrap">1. vi=
rtual_addr =3D dma_alloc_attr(device, size,, phys, GFP_KERNEL, </span></fon=
t><font color=3D"#000000"><span style=3D"white-space:pre-wrap"> </span></fo=
nt>DMA_ATTR_NO_KERNEL_MAPPING=C2=A0<span style=3D"color:rgb(0,0,0);white-sp=
ace:pre-wrap">);</span></div><div><span style=3D"color:rgb(0,0,0);white-spa=
ce:pre-wrap">2. Now i can use phys for driver as physical address and i am =
using in drivers, working fine.</span></div><div><span style=3D"color:rgb(0=
,0,0);white-space:pre-wrap">3. Now i want to use virtual address in kernel =
space(in some cases virtual address required in my driver), not allow to us=
e virtual_addr in kernel space because </span><font color=3D"#000000"><span=
 style=3D"white-space:pre-wrap"> </span></font>DMA_ATTR_NO_KERNEL_MAPPING, =
How can i mapped again to kernel space ?</div><div><span style=3D"color:rgb=
(0,0,0);white-space:pre-wrap"><br></span></div><div><span style=3D"color:rg=
b(0,0,0);white-space:pre-wrap">How can i used  </span>DMA_ATTR_NO_KERNEL_MA=
PPING=C2=A0 and mapped some area for kernel space when needed ?</div><div><=
br></div><div>Is there any apis available ? or improvement is required in l=
inux kernel dma-apis ?</div><div><br></div><div>Regards,</div><div>Pankaj</=
div></div>
</blockquote></div></div>

--000000000000a35b65058c3cbc65--

