Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C8A65C48BD6
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 16:41:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 639D220644
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 16:41:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Pt8+756x"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 639D220644
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C222E8E0003; Wed, 26 Jun 2019 12:41:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BAB3F8E0002; Wed, 26 Jun 2019 12:41:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A72548E0003; Wed, 26 Jun 2019 12:41:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f198.google.com (mail-vk1-f198.google.com [209.85.221.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7DE188E0002
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 12:41:26 -0400 (EDT)
Received: by mail-vk1-f198.google.com with SMTP id d14so1094005vka.6
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 09:41:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:from:date:message-id
         :subject:to;
        bh=uqOa1MjbOZOIjJa9oW3ypx3/wKCsW0EcFsipiDybsyI=;
        b=j0gOk4lN2oibewnzdkYkySN/lHZk8JkjRQutHNvRoCYREIgkDgSJlCUYDygXtsDsGh
         MIihSMufwO3BXYaobMFLcviRk+ZXxWytsU2dACQAEfvpIFUkzCR/ZAUVQW5BOhgr0JQk
         Gfr5k23yhGm+HXE0Wv0OdFRZpKuU8w0lk2QDqYwaWu3ArhmNmzfRUy2SP4eTXZnJwUaC
         UR3dhHGd2ldVRN9ceA7kNbxK6p8zm98prCCi4wvUMceoqQvW6GJcOmmwwv/Xlpo08Bsm
         gvFgMWIe3PKvJ+UDJcBMZ+yCb8H0htpKx/cjl0IgmNfFdVnC8AzWP6muKFnddkjKPQrc
         t0JA==
X-Gm-Message-State: APjAAAWIJ3iWPBegEjmR7tXKHl4yNPXxt0yqsb0NwAfdWyQZmjtXObrg
	8w/EljwRjQ9oLWX+Yka5tNMTAcMnQuMSFm0P54ktuMnybBbsV/S398jpD0xEKUgqW+LDvzbH42o
	GwleHAfajGPZ5RcMq+RvkMKMfAHbwNoTQ1Oxi/j6/00wrWzdP4RwlpSOHArFM6WyTLA==
X-Received: by 2002:ab0:30f5:: with SMTP id d21mr3183332uam.67.1561567286198;
        Wed, 26 Jun 2019 09:41:26 -0700 (PDT)
X-Received: by 2002:ab0:30f5:: with SMTP id d21mr3183298uam.67.1561567285510;
        Wed, 26 Jun 2019 09:41:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561567285; cv=none;
        d=google.com; s=arc-20160816;
        b=Ebevzsf4NZuREWc0vodEpI+zjexSA6Be1PlwQG7Wjq4oq4ukTbcvpuupNjSUaoj8EH
         BYWQdDPdPykCNKnOoLBBeEVdhoSWhRrx2aZ0qfn7cO8K1VpHUs236QBgKWH7LPE4KJSY
         zcFgHsLKJJCArqfiPE2A9C8sIjT8gn661fO3lfNkahvE2h/4BMuaRKx8SpQ1XKx/D8Fz
         eLGcV/qmoWI+Lg309GZSJqLLevyURb4fqmtTZq9wFnwqa01JQ1i5mcqAue1ZozjfXHFV
         cBt6XDYIp8g+bdnCDBUYKxtD3wb6GtopfEpmI/bW2+vWTnS30ey7yupPhhibHQXgCIH1
         62lQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:subject:message-id:date:from:mime-version:dkim-signature;
        bh=uqOa1MjbOZOIjJa9oW3ypx3/wKCsW0EcFsipiDybsyI=;
        b=OI5lyeUcRBnYLbapDqoEQcxOC9GOfOgr1J+nKxbnbYAaLQORB+dfbkQHV1RVPD6Pgh
         Fpqd72NEN+GfMxrhJ8RFriffLn/IOmgyVIOnixLEJ3taw0HRHLSWAA5v+2xogeMEdQel
         8zevWCetXfQIok6oDL9fvzXL7cSyjQA9gGrG8wloFkBKYRjfV3BUI3Uy203ELfQj8dQL
         r6iX/yAj8GtrKHyJRkpNFgWmvCdse1OPfOgvMUMsDQRqDXRarWs6atnGHiUbtRYJvLZ4
         QEhfpztDSgL0YH6YsLCGQT1fhTo4NonCKsLIDcC8aoU5u6syK1QwDRyZPLBDVTNqXHab
         NOjg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Pt8+756x;
       spf=pass (google.com: domain of pankajssuryawanshi@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=pankajssuryawanshi@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id s13sor9983850vsj.55.2019.06.26.09.41.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 26 Jun 2019 09:41:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of pankajssuryawanshi@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Pt8+756x;
       spf=pass (google.com: domain of pankajssuryawanshi@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=pankajssuryawanshi@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:from:date:message-id:subject:to;
        bh=uqOa1MjbOZOIjJa9oW3ypx3/wKCsW0EcFsipiDybsyI=;
        b=Pt8+756xeOyT0It3z97Pqk8ivhDoQ6awGB2r81blkRBLvzPiZwQKP8zh3n5cx/olF4
         spurCq+tQAilbszaTY97BjyQgVsi0LkTkZS/JZb71SDVhgFwwLzegrqSIsN41mSzIM6h
         9hcpMHxIajlFJlyDT40b/afDyC6OPdu8l+KpHp6Tuf7Lq98IVlX380/3VcsicMtvWjUx
         HQGhVHnX94hiwkWjcYKAEMTHM1jCmuFHqm8NqhO+FqYGwNHv3fefGoate/rDOGrsk/1B
         uiqruEHJ4wOfIIJmFEciaD/OHgcNqnIgnOzhvGxIMuXLlPpWcoyZXC3qn6NAxRtT/yLr
         5YKw==
X-Google-Smtp-Source: APXvYqzYW7dqooX5KcE9dKd3UGx/uTtrNgKHfo8a+yG425vi8XRlqNxo2hp8sW5M2V1RLaFiHfAhxFfxVAawKByvPHA=
X-Received: by 2002:a67:2fcd:: with SMTP id v196mr3525779vsv.55.1561567285059;
 Wed, 26 Jun 2019 09:41:25 -0700 (PDT)
MIME-Version: 1.0
From: Pankaj Suryawanshi <pankajssuryawanshi@gmail.com>
Date: Wed, 26 Jun 2019 22:11:16 +0530
Message-ID: <CACDBo564RoWpi8y2pOxoddnn0s3f3sA-fmNxpiXuxebV5TFBJA@mail.gmail.com>
Subject: DMA-API attr - DMA_ATTR_NO_KERNEL_MAPPING
To: linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>
Content-Type: multipart/alternative; boundary="00000000000051a5b6058c3cb782"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--00000000000051a5b6058c3cb782
Content-Type: text/plain; charset="UTF-8"

Hello,

I am writing driver in which I used DMA_ATTR_NO_KERNEL_MAPPING attribute
for cma allocation using dma_alloc_attr(), as per kernel docs
https://www.kernel.org/doc/Documentation/DMA-attributes.txt  buffers
allocated with this attribute can be only passed to user space by calling
dma_mmap_attrs().

how can I mapped in kernel space (after dma_alloc_attr with
DMA_ATTR_NO_KERNEL_MAPPING ) ?

For example.

1. virtual_addr = dma_alloc_attr(device, size,, phys, GFP_KERNEL,
DMA_ATTR_NO_KERNEL_MAPPING );
2. Now i can use phys for driver as physical address and i am using in
drivers, working fine.
3. Now i want to use virtual address in kernel space(in some cases virtual
address required in my driver), not allow to use virtual_addr in kernel
space because DMA_ATTR_NO_KERNEL_MAPPING, How can i mapped again to kernel
space ?

How can i used DMA_ATTR_NO_KERNEL_MAPPING  and mapped some area for kernel
space when needed ?

Is there any apis available ? or improvement is required in linux kernel
dma-apis ?

Regards,
Pankaj

--00000000000051a5b6058c3cb782
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Hello,<br><br>I am writing driver in which I used DMA_ATTR=
_NO_KERNEL_MAPPING attribute for cma allocation using dma_alloc_attr(), as =
per kernel docs=C2=A0<a href=3D"https://www.kernel.org/doc/Documentation/DM=
A-attributes.txt">https://www.kernel.org/doc/Documentation/DMA-attributes.t=
xt</a>=C2=A0 b<span style=3D"color:rgb(0,0,0);white-space:pre-wrap">uffers =
allocated with this attribute can be only passed to user space </span><span=
 style=3D"color:rgb(0,0,0);white-space:pre-wrap">by calling dma_mmap_attrs(=
).</span><div><br></div><div><font color=3D"#000000"><span style=3D"white-s=
pace:pre-wrap">how can I mapped in kernel space (after dma_alloc_attr with =
</span></font>DMA_ATTR_NO_KERNEL_MAPPING=C2=A0<span style=3D"white-space:pr=
e-wrap;color:rgb(0,0,0)">) ?</span></div><div><font color=3D"#000000"><span=
 style=3D"white-space:pre-wrap"><br></span></font></div><div><font color=3D=
"#000000"><span style=3D"white-space:pre-wrap">For example.</span></font></=
div><div><font color=3D"#000000"><span style=3D"white-space:pre-wrap"><br><=
/span></font></div><div><font color=3D"#000000"><span style=3D"white-space:=
pre-wrap">1. virtual_addr =3D dma_alloc_attr(device, size,, phys, GFP_KERNE=
L, </span></font><font color=3D"#000000"><span style=3D"white-space:pre-wra=
p"> </span></font>DMA_ATTR_NO_KERNEL_MAPPING=C2=A0<span style=3D"color:rgb(=
0,0,0);white-space:pre-wrap">);</span></div><div><span style=3D"color:rgb(0=
,0,0);white-space:pre-wrap">2. Now i can use phys for driver as physical ad=
dress and i am using in drivers, working fine.</span></div><div><span style=
=3D"color:rgb(0,0,0);white-space:pre-wrap">3. Now i want to use virtual add=
ress in kernel space(in some cases virtual address required in my driver), =
not allow to use virtual_addr in kernel space because </span><font color=3D=
"#000000"><span style=3D"white-space:pre-wrap"> </span></font>DMA_ATTR_NO_K=
ERNEL_MAPPING, How can i mapped again to kernel space ?</div><div><span sty=
le=3D"color:rgb(0,0,0);white-space:pre-wrap"><br></span></div><div><span st=
yle=3D"color:rgb(0,0,0);white-space:pre-wrap">How can i used  </span>DMA_AT=
TR_NO_KERNEL_MAPPING=C2=A0 and mapped some area for kernel space when neede=
d ?</div><div><br></div><div>Is there any apis available ? or improvement i=
s required in linux kernel dma-apis ?</div><div><br></div><div>Regards,</di=
v><div>Pankaj</div></div>

--00000000000051a5b6058c3cb782--

