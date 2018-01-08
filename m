Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 214186B026D
	for <linux-mm@kvack.org>; Mon,  8 Jan 2018 15:25:57 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id y62so8451944pfd.3
        for <linux-mm@kvack.org>; Mon, 08 Jan 2018 12:25:57 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h90si8996299plb.644.2018.01.08.12.25.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 08 Jan 2018 12:25:55 -0800 (PST)
Date: Mon, 8 Jan 2018 21:25:48 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: revamp vmem_altmap / dev_pagemap handling V3
Message-ID: <20180108202548.GA1732@dhcp22.suse.cz>
References: <20171229075406.1936-1-hch@lst.de>
 <20180108112646.GA7204@lst.de>
 <CAPcyv4hHipDHP5LZCgym5szqiUSCxG9wQUbRO_qe8T+USaZi9Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4hHipDHP5LZCgym5szqiUSCxG9wQUbRO_qe8T+USaZi9Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Christoph Hellwig <hch@lst.de>, linux-nvdimm@lists.01.org, X86 ML <x86@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>

On Mon 08-01-18 11:44:02, Dan Williams wrote:
> On Mon, Jan 8, 2018 at 3:26 AM, Christoph Hellwig <hch@lst.de> wrote:
> > Any chance to get this fully reviewed and picked up before the
> > end of the merge window?
> 
> I'm fine carrying these through the nvdimm tree, but I'd need an ack
> from the mm folks for all the code touches related to arch_add_memory.

I am sorry to be slow here but I am out of time right now - yeah having
a lot of fun kaiser time. I didn't get to look at these patches at all
yet but the changelog suggests that you want to remove vmem_altmap.
I've had plans to (ab)use this for self hosted struct pages for memory
hotplug http://lkml.kernel.org/r/20170801124111.28881-1-mhocko@kernel.org
That work is stalled though because it is buggy and I was too busy to
finish that work. Anyway, if you believe that removing vmem_altmap is a
good step in general I will find another way. I wasn't really happy how
the whole thing is grafted to the memory hotplug and (ab)used it only
because it was handy and ready for reuse.

Anyway if you need a review of mm parts from me, you will have to wait
some more. If this requires some priority then go ahead and merge
it. Times are just too crazy right now.

Sorry about that.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
