Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id C560D6B0274
	for <linux-mm@kvack.org>; Mon,  8 Jan 2018 16:27:14 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id r141so3928871oie.9
        for <linux-mm@kvack.org>; Mon, 08 Jan 2018 13:27:14 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id y9sor4357374oig.67.2018.01.08.13.27.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 08 Jan 2018 13:27:13 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180108202548.GA1732@dhcp22.suse.cz>
References: <20171229075406.1936-1-hch@lst.de> <20180108112646.GA7204@lst.de>
 <CAPcyv4hHipDHP5LZCgym5szqiUSCxG9wQUbRO_qe8T+USaZi9Q@mail.gmail.com> <20180108202548.GA1732@dhcp22.suse.cz>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 8 Jan 2018 13:27:13 -0800
Message-ID: <CAPcyv4ipGv613NgJZ8HEWTV4DrDxRdrMwD=8odZevvBQaQwuCA@mail.gmail.com>
Subject: Re: revamp vmem_altmap / dev_pagemap handling V3
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Christoph Hellwig <hch@lst.de>, linux-nvdimm@lists.01.org, X86 ML <x86@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>

On Mon, Jan 8, 2018 at 12:25 PM, Michal Hocko <mhocko@kernel.org> wrote:
> On Mon 08-01-18 11:44:02, Dan Williams wrote:
>> On Mon, Jan 8, 2018 at 3:26 AM, Christoph Hellwig <hch@lst.de> wrote:
>> > Any chance to get this fully reviewed and picked up before the
>> > end of the merge window?
>>
>> I'm fine carrying these through the nvdimm tree, but I'd need an ack
>> from the mm folks for all the code touches related to arch_add_memory.
>
> I am sorry to be slow here but I am out of time right now - yeah having
> a lot of fun kaiser time. I didn't get to look at these patches at all
> yet but the changelog suggests that you want to remove vmem_altmap.
> I've had plans to (ab)use this for self hosted struct pages for memory
> hotplug http://lkml.kernel.org/r/20170801124111.28881-1-mhocko@kernel.org
> That work is stalled though because it is buggy and I was too busy to
> finish that work. Anyway, if you believe that removing vmem_altmap is a
> good step in general I will find another way. I wasn't really happy how
> the whole thing is grafted to the memory hotplug and (ab)used it only
> because it was handy and ready for reuse.

You misread, these are keeping vmem_altmap and cleaning up the usage
to pass the vmem_altmap pointer through all paths rather than the
tricky radix lookup we were doing previously.

> Anyway if you need a review of mm parts from me, you will have to wait
> some more. If this requires some priority then go ahead and merge
> it. Times are just too crazy right now.

Since you were planning on reusing vmem_altmap I think these patches
make your job easier. I don't see the risk in merging these, we've
squeezed out a few bugs and all the nvdimm unit tests are passing.

> Sorry about that.

No worries, quite a few of us are in that same boat.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
