Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9D03B8E0001
	for <linux-mm@kvack.org>; Thu, 27 Dec 2018 00:13:53 -0500 (EST)
Received: by mail-oi1-f199.google.com with SMTP id h85so12599520oib.9
        for <linux-mm@kvack.org>; Wed, 26 Dec 2018 21:13:53 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a96sor23608023otb.28.2018.12.26.21.13.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 26 Dec 2018 21:13:52 -0800 (PST)
MIME-Version: 1.0
References: <20181226131446.330864849@intel.com> <20181226133351.106676005@intel.com>
 <20181227034141.GD20878@bombadil.infradead.org> <20181227041132.xxdnwtdajtm7ny4q@wfg-t540p.sh.intel.com>
In-Reply-To: <20181227041132.xxdnwtdajtm7ny4q@wfg-t540p.sh.intel.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 26 Dec 2018 21:13:41 -0800
Message-ID: <CAPcyv4hBBvcHiUSU4ER6WV7Po_GEwDjFcJy2aE3VW5Nwiu+Qyw@mail.gmail.com>
Subject: Re: [RFC][PATCH v2 01/21] e820: cheat PMEM as DRAM
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Fan Du <fan.du@intel.com>, KVM list <kvm@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Yao Yuan <yuan.yao@intel.com>, Peng Dong <dongx.peng@intel.com>, Huang Ying <ying.huang@intel.com>, Liu Jingqi <jingqi.liu@intel.com>, Dong Eddie <eddie.dong@intel.com>, Dave Hansen <dave.hansen@intel.com>, Zhang Yi <yi.z.zhang@linux.intel.com>

On Wed, Dec 26, 2018 at 8:11 PM Fengguang Wu <fengguang.wu@intel.com> wrote:
>
> On Wed, Dec 26, 2018 at 07:41:41PM -0800, Matthew Wilcox wrote:
> >On Wed, Dec 26, 2018 at 09:14:47PM +0800, Fengguang Wu wrote:
> >> From: Fan Du <fan.du@intel.com>
> >>
> >> This is a hack to enumerate PMEM as NUMA nodes.
> >> It's necessary for current BIOS that don't yet fill ACPI HMAT table.
> >>
> >> WARNING: take care to backup. It is mutual exclusive with libnvdimm
> >> subsystem and can destroy ndctl managed namespaces.
> >
> >Why depend on firmware to present this "correctly"?  It seems to me like
> >less effort all around to have ndctl label some namespaces as being for
> >this kind of use.
>
> Dave Hansen may be more suitable to answer your question. He posted
> patches to make PMEM NUMA node coexist with libnvdimm and ndctl:
>
> [PATCH 0/9] Allow persistent memory to be used like normal RAM
> https://lkml.org/lkml/2018/10/23/9
>
> That depends on future BIOS. So we did this quick hack to test out
> PMEM NUMA node for the existing BIOS.

No, it does not depend on a future BIOS.

Willy, have a look here [1], here [2], and here [3] for the
work-in-progress ndctl takeover approach (actually 'daxctl' in this
case).

[1]: https://lkml.org/lkml/2018/10/23/9
[2]: https://lkml.org/lkml/2018/10/31/243
[3]: https://lists.01.org/pipermail/linux-nvdimm/2018-November/018677.html
