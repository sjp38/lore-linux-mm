Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 8816E6B0032
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 12:36:24 -0400 (EDT)
Received: by wibdq8 with SMTP id dq8so91528745wib.1
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 09:36:24 -0700 (PDT)
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com. [209.85.212.171])
        by mx.google.com with ESMTPS id d4si2282494wie.32.2015.06.08.09.36.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Jun 2015 09:36:22 -0700 (PDT)
Received: by wiga1 with SMTP id a1so92591491wig.0
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 09:36:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F32A8E39B@ORSMSX114.amr.corp.intel.com>
References: <55704A7E.5030507@huawei.com> <55704B0C.1000308@huawei.com>
 <CALq1K=J7BuqMDkPrjioRVyRedHLhmM-gg8MOb9GSBcrmNah23g@mail.gmail.com> <3908561D78D1C84285E8C5FCA982C28F32A8E39B@ORSMSX114.amr.corp.intel.com>
From: Leon Romanovsky <leon@leon.nu>
Date: Mon, 8 Jun 2015 19:36:01 +0300
Message-ID: <CALq1K=J8ndi6tfy6nV3BT85bp1FXzxO8+mD9KgBfBpz6ibK7Hg@mail.gmail.com>
Subject: Re: [RFC PATCH 01/12] mm: add a new config to manage the code
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Xishi Qiu <qiuxishi@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, "nao.horiguchi@gmail.com" <nao.horiguchi@gmail.com>, Yinghai Lu <yinghai@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, "mingo@elte.hu" <mingo@elte.hu>, Xiexiuqi <xiexiuqi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Jun 8, 2015 at 6:14 PM, Luck, Tony <tony.luck@intel.com> wrote:
>> > +config MEMORY_MIRROR
>> > +       bool "Address range mirroring support"
>> > +       depends on X86 && NUMA
>> > +       default y
>> Is it correct for the systems (NOT xeon) without memory support built in=
?
>
> Is the "&& NUMA" doing that?  If you support NUMA, then you are not a min=
imal
> config for a tablet or laptop.
>
> If you want a symbol that has a stronger correlation to high end Xeon fea=
tures
> then perhaps MEMORY_FAILURE?
I would like to see the default set to be "n".
On my machine (x86_64) defconfig enables this feature and I don't know
if this feature can work there.

=E2=9E=9C  linux-mm git:(dev) =E2=9C=97 make defconfig ARCH=3Dx86
  HOSTCC  scripts/basic/fixdep
  HOSTCC  scripts/basic/bin2c
  HOSTCC  scripts/kconfig/conf.o
  HOSTCC  scripts/kconfig/zconf.tab.o
  HOSTLD  scripts/kconfig/conf
*** Default configuration is based on 'x86_64_defconfig'
#
# configuration written to .config
#
=E2=9E=9C  linux-mm git:(dev) =E2=9C=97 grep CONFIG_MEMORY_MIRROR .config
CONFIG_MEMORY_MIRROR=3Dy


>
> -Tony



--=20
Leon Romanovsky | Independent Linux Consultant
        www.leon.nu | leon@leon.nu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
