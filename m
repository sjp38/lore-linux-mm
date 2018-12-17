Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 938138E0001
	for <linux-mm@kvack.org>; Mon, 17 Dec 2018 08:35:19 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id i55so8773372ede.14
        for <linux-mm@kvack.org>; Mon, 17 Dec 2018 05:35:19 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d8-v6si4261228ejw.84.2018.12.17.05.35.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Dec 2018 05:35:18 -0800 (PST)
Date: Mon, 17 Dec 2018 14:35:16 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 1/1] mm, memory_hotplug: Initialize struct pages for
 the full memory section
Message-ID: <20181217133516.GO30879@dhcp22.suse.cz>
References: <20181212172712.34019-1-zaslonko@linux.ibm.com>
 <20181212172712.34019-2-zaslonko@linux.ibm.com>
 <476a80cb-5524-16c1-6dd5-da5febbd6139@redhat.com>
 <bcd0c49c-e417-ef8b-996f-99ecef540d9c@redhat.com>
 <20181214202315.1c685f1e@thinkpad>
 <cffab731-81e0-b80c-665e-c9a62faed4ec@redhat.com>
 <20181217122812.GJ30879@dhcp22.suse.cz>
 <8b1bc4ff-0a30-573c-94c3-a8d943cd291c@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8b1bc4ff-0a30-573c-94c3-a8d943cd291c@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: Gerald Schaefer <gerald.schaefer@de.ibm.com>, Mikhail Zaslonko <zaslonko@linux.ibm.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pavel.Tatashin@microsoft.com, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com

On Mon 17-12-18 14:29:04, David Hildenbrand wrote:
> On 17.12.18 13:28, Michal Hocko wrote:
> > On Mon 17-12-18 10:38:32, David Hildenbrand wrote:
> > [...]
> >> I am wondering if we should fix this on the memblock level instead than.
> >> Something like, before handing memory over to the page allocator, add
> >> memory as reserved up to the last section boundary. Or even when setting
> >> the physical memory limit (mem= scenario).
> > 
> > Memory initialization is spread over several places and that makes it
> > really hard to grasp and maintain. I do not really see why we should
> > make memblock even more special. We do intialize the section worth of
> > memory here so it sounds like a proper place to quirk for incomplete
> > sections.
> > 
> 
> True as well. The reason I am asking is, that memblock usually takes
> care of physical memory holes.

Yes and no. It only reflects existing memory ranges (so yes it skips
over holes) and then it provides an API that platform/arch code can
abuse to cut holes into existing ranges.
-- 
Michal Hocko
SUSE Labs
