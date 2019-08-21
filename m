Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_2 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 11A02C3A59E
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 21:12:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A66A3206DD
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 21:12:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="jWiovE0W"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A66A3206DD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4BB9B6B02AB; Wed, 21 Aug 2019 17:12:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 46C326B02AC; Wed, 21 Aug 2019 17:12:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 35C2D6B02AD; Wed, 21 Aug 2019 17:12:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0022.hostedemail.com [216.40.44.22])
	by kanga.kvack.org (Postfix) with ESMTP id 10EDC6B02AB
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 17:12:12 -0400 (EDT)
Received: from smtpin22.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id AB0F48248AB4
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 21:12:11 +0000 (UTC)
X-FDA: 75847682862.22.boys82_877e81aa27e45
X-HE-Tag: boys82_877e81aa27e45
X-Filterd-Recvd-Size: 9967
Received: from mail-qk1-f194.google.com (mail-qk1-f194.google.com [209.85.222.194])
	by imf50.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 21:12:10 +0000 (UTC)
Received: by mail-qk1-f194.google.com with SMTP id g17so3165895qkk.8
        for <linux-mm@kvack.org>; Wed, 21 Aug 2019 14:12:10 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=wKfoGD8n1EExPN/R416sVnt2YzIc0+Wi95CWXfv+Qwc=;
        b=jWiovE0WVWyuoSRn6Q6NcWiLlhDCr9SDx17bU42gfmxyhc87oSxHk+qHbYQygjSfT+
         tH6VXnvSQoPDO+HDRApqHP4MObAmzQzTMzR6FKHuYJC0tiQ5dn1Zjbc24IAQyM6CaIAW
         YQLNp62YoI8b/iy9qxXFMbmXwdZGaGuNw3hvqWAqz8kcU+qZ6Q9q/f83Gr+jG/Exj/S3
         AGV4XoW0HaHZ3fJZj349TaO5HvUvu1Mfqtyf+s54/WqqEJkysXIDIXTeOLSb2nMSMuDQ
         gLY6v4P4ZNk/rp6JLor6rfPfkfOcLrPtuvUqTzN1BpVfGlgGoChwtv4vh3mihM+QR7f+
         8vvA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:message-id:subject:from:to:cc:date:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=wKfoGD8n1EExPN/R416sVnt2YzIc0+Wi95CWXfv+Qwc=;
        b=rkG3R+eF373Y43xf+W+IR/wi6DyaR5ZxCotPrrJLRTbI1/RaIb3vWFv08KrZ45w3u6
         uSIQBJNJnroyXq/INfC5nz/C7vRsN/aPhA++C4Bsi/u7mSKHz8PjD42XdUtjlghQP3H2
         IUrCPFkHNbsThmMimoFJe04I+LCu2bBfnRbOchbchPOSFDGgSRGrf1/QqXU9SfKG3shx
         ZTXSxnDOWp/DwrkA5nlI8ZWW86qLUYSr2BEPB9oh342CWWtXlr6Lb8DfAV2eJvF12XmO
         R0swO+sWOS7wkkTE/ui7WgbUlGMNJlseQGi1hHkBSrhybc90J9gxxc/7TzY7XMbK5U4U
         3tRg==
X-Gm-Message-State: APjAAAWGbQaAZE2oWEe7bMYJWufyYS1ccJF8qceNcZUMfQpBkw6hb0NS
	/NC27/thKLPmpuetnn1Wex6NGw==
X-Google-Smtp-Source: APXvYqwZ/bY1z3XLINRGQysL7fa2x5zQOYp0Z/0iOTKQ6+P8g3Nz+pt9/o+NHkYuXYYVlhIkIK4F5A==
X-Received: by 2002:ae9:ef06:: with SMTP id d6mr33003385qkg.157.1566421930297;
        Wed, 21 Aug 2019 14:12:10 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id z22sm5710821qti.1.2019.08.21.14.12.08
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Aug 2019 14:12:09 -0700 (PDT)
Message-ID: <1566421927.5576.3.camel@lca.pw>
Subject: Re: devm_memremap_pages() triggers a kasan_add_zero_shadow() warning
From: Qian Cai <cai@lca.pw>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Linux MM <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@lists.01.org>,
  Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrey Ryabinin
 <aryabinin@virtuozzo.com>, kasan-dev@googlegroups.com,  Baoquan He
 <bhe@redhat.com>, Dave Jiang <dave.jiang@intel.com>, Thomas Gleixner
 <tglx@linutronix.de>
Date: Wed, 21 Aug 2019 17:12:07 -0400
In-Reply-To: <0AC959D7-5BCB-4A81-BBDC-990E9826EB45@lca.pw>
References: <1565991345.8572.28.camel@lca.pw>
	 <CAPcyv4i9VFLSrU75U0gQH6K2sz8AZttqvYidPdDcS7sU2SFaCA@mail.gmail.com>
	 <0FB85A78-C2EE-4135-9E0F-D5623CE6EA47@lca.pw>
	 <CAPcyv4h9Y7wSdF+jnNzLDRobnjzLfkGLpJsML2XYLUZZZUPsQA@mail.gmail.com>
	 <E7A04694-504D-4FB3-9864-03C2CBA3898E@lca.pw>
	 <CAPcyv4gofF-Xf0KTLH4EUkxuXdRO3ha-w+GoxgmiW7gOdS2nXQ@mail.gmail.com>
	 <0AC959D7-5BCB-4A81-BBDC-990E9826EB45@lca.pw>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 2019-08-17 at 23:25 -0400, Qian Cai wrote:
> > On Aug 17, 2019, at 12:59 PM, Dan Williams <dan.j.williams@intel.com>=
 wrote:
> >=20
> > On Sat, Aug 17, 2019 at 4:13 AM Qian Cai <cai@lca.pw> wrote:
> > >=20
> > >=20
> > >=20
> > > > On Aug 16, 2019, at 11:57 PM, Dan Williams <dan.j.williams@intel.=
com>
> > > > wrote:
> > > >=20
> > > > On Fri, Aug 16, 2019 at 8:34 PM Qian Cai <cai@lca.pw> wrote:
> > > > >=20
> > > > >=20
> > > > >=20
> > > > > > On Aug 16, 2019, at 5:48 PM, Dan Williams <dan.j.williams@int=
el.com>
> > > > > > wrote:
> > > > > >=20
> > > > > > On Fri, Aug 16, 2019 at 2:36 PM Qian Cai <cai@lca.pw> wrote:
> > > > > > >=20
> > > > > > > Every so often recently, booting Intel CPU server on linux-=
next
> > > > > > > triggers this
> > > > > > > warning. Trying to figure out if=C2=A0=C2=A0the commit 7cc7=
867fb061
> > > > > > > ("mm/devm_memremap_pages: enable sub-section remap") is the
> > > > > > > culprit here.
> > > > > > >=20
> > > > > > > # ./scripts/faddr2line vmlinux devm_memremap_pages+0x894/0x=
c70
> > > > > > > devm_memremap_pages+0x894/0xc70:
> > > > > > > devm_memremap_pages at mm/memremap.c:307
> > > > > >=20
> > > > > > Previously the forced section alignment in devm_memremap_page=
s()
> > > > > > would
> > > > > > cause the implementation to never violate the
> > > > > > KASAN_SHADOW_SCALE_SIZE
> > > > > > (12K on x86) constraint.
> > > > > >=20
> > > > > > Can you provide a dump of /proc/iomem? I'm curious what resou=
rce is
> > > > > > triggering such a small alignment granularity.
> > > > >=20
> > > > > This is with memmap=3D4G!4G ,
> > > > >=20
> > > > > # cat /proc/iomem
> > > >=20
> > > > [..]
> > > > > 100000000-155dfffff : Persistent Memory (legacy)
> > > > > 100000000-155dfffff : namespace0.0
> > > > > 155e00000-15982bfff : System RAM
> > > > > 155e00000-156a00fa0 : Kernel code
> > > > > 156a00fa1-15765d67f : Kernel data
> > > > > 157837000-1597fffff : Kernel bss
> > > > > 15982c000-1ffffffff : Persistent Memory (legacy)
> > > > > 200000000-87fffffff : System RAM
> > > >=20
> > > > Ok, looks like 4G is bad choice to land the pmem emulation on thi=
s
> > > > system because it collides with where the kernel is deployed and =
gets
> > > > broken into tiny pieces that violate kasan's. This is a known pro=
blem
> > > > with memmap=3D. You need to pick an memory range that does not co=
llide
> > > > with anything else. See:
> > > >=20
> > > > =C2=A0 https://nvdimm.wiki.kernel.org/how_to_choose_the_correct_m=
emmap_kernel
> > > > _parameter_for_pmem_on_your_system
> > > >=20
> > > > ...for more info.
> > >=20
> > > Well, it seems I did exactly follow the information in that link,
> > >=20
> > > [=C2=A0=C2=A0=C2=A0=C2=A00.000000] BIOS-provided physical RAM map:
> > > [=C2=A0=C2=A0=C2=A0=C2=A00.000000] BIOS-e820: [mem 0x00000000000000=
00-0x0000000000093fff]
> > > usable
> > > [=C2=A0=C2=A0=C2=A0=C2=A00.000000] BIOS-e820: [mem 0x00000000000940=
00-0x000000000009ffff]
> > > reserved
> > > [=C2=A0=C2=A0=C2=A0=C2=A00.000000] BIOS-e820: [mem 0x00000000000e00=
00-0x00000000000fffff]
> > > reserved
> > > [=C2=A0=C2=A0=C2=A0=C2=A00.000000] BIOS-e820: [mem 0x00000000001000=
00-0x000000005a7a0fff]
> > > usable
> > > [=C2=A0=C2=A0=C2=A0=C2=A00.000000] BIOS-e820: [mem 0x000000005a7a10=
00-0x000000005b5e0fff]
> > > reserved
> > > [=C2=A0=C2=A0=C2=A0=C2=A00.000000] BIOS-e820: [mem 0x000000005b5e10=
00-0x00000000790fefff]
> > > usable
> > > [=C2=A0=C2=A0=C2=A0=C2=A00.000000] BIOS-e820: [mem 0x00000000790ff0=
00-0x00000000791fefff]
> > > reserved
> > > [=C2=A0=C2=A0=C2=A0=C2=A00.000000] BIOS-e820: [mem 0x00000000791ff0=
00-0x000000007b5fefff] ACPI
> > > NVS
> > > [=C2=A0=C2=A0=C2=A0=C2=A00.000000] BIOS-e820: [mem 0x000000007b5ff0=
00-0x000000007b7fefff] ACPI
> > > data
> > > [=C2=A0=C2=A0=C2=A0=C2=A00.000000] BIOS-e820: [mem 0x000000007b7ff0=
00-0x000000007b7fffff]
> > > usable
> > > [=C2=A0=C2=A0=C2=A0=C2=A00.000000] BIOS-e820: [mem 0x000000007b8000=
00-0x000000008fffffff]
> > > reserved
> > > [=C2=A0=C2=A0=C2=A0=C2=A00.000000] BIOS-e820: [mem 0x00000000ff8000=
00-0x00000000ffffffff]
> > > reserved
> > > [=C2=A0=C2=A0=C2=A0=C2=A00.000000] BIOS-e820: [mem 0x00000001000000=
00-0x000000087fffffff]
> > > usable
> > >=20
> > > Where 4G is good. Then,
> > >=20
> > > [=C2=A0=C2=A0=C2=A0=C2=A00.000000] user-defined physical RAM map:
> > > [=C2=A0=C2=A0=C2=A0=C2=A00.000000] user: [mem 0x0000000000000000-0x=
0000000000093fff] usable
> > > [=C2=A0=C2=A0=C2=A0=C2=A00.000000] user: [mem 0x0000000000094000-0x=
000000000009ffff] reserved
> > > [=C2=A0=C2=A0=C2=A0=C2=A00.000000] user: [mem 0x00000000000e0000-0x=
00000000000fffff] reserved
> > > [=C2=A0=C2=A0=C2=A0=C2=A00.000000] user: [mem 0x0000000000100000-0x=
000000005a7a0fff] usable
> > > [=C2=A0=C2=A0=C2=A0=C2=A00.000000] user: [mem 0x000000005a7a1000-0x=
000000005b5e0fff] reserved
> > > [=C2=A0=C2=A0=C2=A0=C2=A00.000000] user: [mem 0x000000005b5e1000-0x=
00000000790fefff] usable
> > > [=C2=A0=C2=A0=C2=A0=C2=A00.000000] user: [mem 0x00000000790ff000-0x=
00000000791fefff] reserved
> > > [=C2=A0=C2=A0=C2=A0=C2=A00.000000] user: [mem 0x00000000791ff000-0x=
000000007b5fefff] ACPI NVS
> > > [=C2=A0=C2=A0=C2=A0=C2=A00.000000] user: [mem 0x000000007b5ff000-0x=
000000007b7fefff] ACPI data
> > > [=C2=A0=C2=A0=C2=A0=C2=A00.000000] user: [mem 0x000000007b7ff000-0x=
000000007b7fffff] usable
> > > [=C2=A0=C2=A0=C2=A0=C2=A00.000000] user: [mem 0x000000007b800000-0x=
000000008fffffff] reserved
> > > [=C2=A0=C2=A0=C2=A0=C2=A00.000000] user: [mem 0x00000000ff800000-0x=
00000000ffffffff] reserved
> > > [=C2=A0=C2=A0=C2=A0=C2=A00.000000] user: [mem 0x0000000100000000-0x=
00000001ffffffff]
> > > persistent (type 12)
> > > [=C2=A0=C2=A0=C2=A0=C2=A00.000000] user: [mem 0x0000000200000000-0x=
000000087fffffff] usable
> > >=20
> > > The doc did mention that =E2=80=9CThere seems to be an issue with C=
ONFIG_KSAN at
> > > the moment however.=E2=80=9D
> > > without more detail though.
> >=20
> > Does disabling CONFIG_RANDOMIZE_BASE help? Maybe that workaround has
> > regressed. Effectively we need to find what is causing the kernel to
> > sometimes be placed in the middle of a custom reserved memmap=3D rang=
e.
>=20
> Yes, disabling KASLR works good so far. Assuming the workaround, i.e.,
> f28442497b5c
> (=E2=80=9Cx86/boot: Fix KASLR and memmap=3D collision=E2=80=9D) is corr=
ect.
>=20
> The only other commit that might regress it from my research so far is,
>=20
> d52e7d5a952c ("x86/KASLR: Parse all 'memmap=3D' boot option entries=E2=80=
=9D)
>=20

It turns out that the origin commit f28442497b5c (=E2=80=9Cx86/boot: Fix =
KASLR and
memmap=3D collision=E2=80=9D) has a bug that is unable to handle "memmap=3D=
" in
CONFIG_CMDLINE instead of a parameter in bootloader because when it (as w=
ell as
the commit d52e7d5a952c) calls get_cmd_line_ptr() in order to run
mem_avoid_memmap(), "boot_params" has no knowledge of CONFIG_CMDLINE. Onl=
y later
in setup_arch(), the kernel will deal with parameters over there.

