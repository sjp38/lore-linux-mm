Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id E7B5E6B000D
	for <linux-mm@kvack.org>; Mon,  7 May 2018 15:08:36 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id 187so7010412qkh.16
        for <linux-mm@kvack.org>; Mon, 07 May 2018 12:08:36 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id o16-v6si3518487qvc.68.2018.05.07.12.08.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 May 2018 12:08:36 -0700 (PDT)
From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [RFC PATCH v1 0/6] use mm to manage NVDIMM (pmem) zone
References: <1525704627-30114-1-git-send-email-yehs1@lenovo.com>
	<20180507184622.GB12361@bombadil.infradead.org>
	<CAPcyv4hBJN3npXwg3Ur32JSWtKvBUZh7F8W+Exx3BB-uKWwPag@mail.gmail.com>
Date: Mon, 07 May 2018 15:08:32 -0400
In-Reply-To: <CAPcyv4hBJN3npXwg3Ur32JSWtKvBUZh7F8W+Exx3BB-uKWwPag@mail.gmail.com>
	(Dan Williams's message of "Mon, 7 May 2018 11:57:10 -0700")
Message-ID: <x49a7tbi8r3.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>, Huaisheng Ye <yehs1@lenovo.com>, linux-nvdimm <linux-nvdimm@lists.01.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, chengnt@lenovo.com, Dave Hansen <dave.hansen@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, pasha.tatashin@oracle.com, Linux MM <linux-mm@kvack.org>, colyli@suse.de, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <alexander.levin@verizon.com>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>

Dan Williams <dan.j.williams@intel.com> writes:

> On Mon, May 7, 2018 at 11:46 AM, Matthew Wilcox <willy@infradead.org> wro=
te:
>> On Mon, May 07, 2018 at 10:50:21PM +0800, Huaisheng Ye wrote:
>>> Traditionally, NVDIMMs are treated by mm(memory management) subsystem as
>>> DEVICE zone, which is a virtual zone and both its start and end of pfn
>>> are equal to 0, mm wouldn=E2=80=99t manage NVDIMM directly as DRAM, ker=
nel uses
>>> corresponding drivers, which locate at \drivers\nvdimm\ and
>>> \drivers\acpi\nfit and fs, to realize NVDIMM memory alloc and free with
>>> memory hot plug implementation.
>>
>> You probably want to let linux-nvdimm know about this patch set.
>> Adding to the cc.
>
> Yes, thanks for that!
>
>> Also, I only received patch 0 and 4.  What happened
>> to 1-3,5 and 6?
>>
>>> With current kernel, many mm=E2=80=99s classical features like the buddy
>>> system, swap mechanism and page cache couldn=E2=80=99t be supported to =
NVDIMM.
>>> What we are doing is to expand kernel mm=E2=80=99s capacity to make it =
to handle
>>> NVDIMM like DRAM. Furthermore we make mm could treat DRAM and NVDIMM
>>> separately, that means mm can only put the critical pages to NVDIMM

Please define "critical pages."

>>> zone, here we created a new zone type as NVM zone. That is to say for
>>> traditional(or normal) pages which would be stored at DRAM scope like
>>> Normal, DMA32 and DMA zones. But for the critical pages, which we hope
>>> them could be recovered from power fail or system crash, we make them
>>> to be persistent by storing them to NVM zone.

[...]

> I think adding yet one more mm-zone is the wrong direction. Instead,
> what we have been considering is a mechanism to allow a device-dax
> instance to be given back to the kernel as a distinct numa node
> managed by the VM. It seems it times to dust off those patches.

What's the use case?  The above patch description seems to indicate an
intent to recover contents after a power loss.  Without seeing the whole
series, I'm not sure how that's accomplished in a safe or meaningful
way.

Huaisheng, could you provide a bit more background?

Thanks!
Jeff
