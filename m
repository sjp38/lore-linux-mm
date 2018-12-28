Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id E978E8E0001
	for <linux-mm@kvack.org>; Thu, 27 Dec 2018 22:27:50 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id m16so19052760pgd.0
        for <linux-mm@kvack.org>; Thu, 27 Dec 2018 19:27:50 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id d189si39661335pfa.70.2018.12.27.19.27.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Dec 2018 19:27:49 -0800 (PST)
Date: Fri, 28 Dec 2018 11:27:44 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [RFC][PATCH v2 01/21] e820: cheat PMEM as DRAM
Message-ID: <20181228032744.i6d7g7ykdi7hjrai@wfg-t540p.sh.intel.com>
References: <20181226131446.330864849@intel.com>
 <20181226133351.106676005@intel.com>
 <20181227034141.GD20878@bombadil.infradead.org>
 <20181227041132.xxdnwtdajtm7ny4q@wfg-t540p.sh.intel.com>
 <CAPcyv4hBBvcHiUSU4ER6WV7Po_GEwDjFcJy2aE3VW5Nwiu+Qyw@mail.gmail.com>
 <CAHbLzkqR2z+wcVXkKRoHysXtjtn12P33emr15h_HB=jMaByV5w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <CAHbLzkqR2z+wcVXkKRoHysXtjtn12P33emr15h_HB=jMaByV5w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <shy828301@gmail.com>
Cc: Dan Williams <dan.j.williams@intel.com>, Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Fan Du <fan.du@intel.com>, KVM list <kvm@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Yao Yuan <yuan.yao@intel.com>, Peng Dong <dongx.peng@intel.com>, Huang Ying <ying.huang@intel.com>, Liu Jingqi <jingqi.liu@intel.com>, Dong Eddie <eddie.dong@intel.com>, Dave Hansen <dave.hansen@intel.com>, Zhang Yi <yi.z.zhang@linux.intel.com>

On Thu, Dec 27, 2018 at 11:32:06AM -0800, Yang Shi wrote:
>On Wed, Dec 26, 2018 at 9:13 PM Dan Williams <dan.j.williams@intel.com> wrote:
>>
>> On Wed, Dec 26, 2018 at 8:11 PM Fengguang Wu <fengguang.wu@intel.com> wrote:
>> >
>> > On Wed, Dec 26, 2018 at 07:41:41PM -0800, Matthew Wilcox wrote:
>> > >On Wed, Dec 26, 2018 at 09:14:47PM +0800, Fengguang Wu wrote:
>> > >> From: Fan Du <fan.du@intel.com>
>> > >>
>> > >> This is a hack to enumerate PMEM as NUMA nodes.
>> > >> It's necessary for current BIOS that don't yet fill ACPI HMAT table.
>> > >>
>> > >> WARNING: take care to backup. It is mutual exclusive with libnvdimm
>> > >> subsystem and can destroy ndctl managed namespaces.
>> > >
>> > >Why depend on firmware to present this "correctly"?  It seems to me like
>> > >less effort all around to have ndctl label some namespaces as being for
>> > >this kind of use.
>> >
>> > Dave Hansen may be more suitable to answer your question. He posted
>> > patches to make PMEM NUMA node coexist with libnvdimm and ndctl:
>> >
>> > [PATCH 0/9] Allow persistent memory to be used like normal RAM
>> > https://lkml.org/lkml/2018/10/23/9
>> >
>> > That depends on future BIOS. So we did this quick hack to test out
>> > PMEM NUMA node for the existing BIOS.
>>
>> No, it does not depend on a future BIOS.
>
>It is correct. We already have Dave's patches + Dan's patch (added
>target_node field) work on our machine which has SRAT.

Thanks for the correction. It looks my perception was out of date.
So we can follow Dave+Dan's patches to create the PMEM NUMA nodes.

Thanks,
Fengguang

>>
>> Willy, have a look here [1], here [2], and here [3] for the
>> work-in-progress ndctl takeover approach (actually 'daxctl' in this
>> case).
>>
>> [1]: https://lkml.org/lkml/2018/10/23/9
>> [2]: https://lkml.org/lkml/2018/10/31/243
>> [3]: https://lists.01.org/pipermail/linux-nvdimm/2018-November/018677.html
>>
>
