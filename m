Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id A76006B025C
	for <linux-mm@kvack.org>; Mon,  7 Dec 2015 11:21:05 -0500 (EST)
Received: by wmuu63 with SMTP id u63so147344159wmu.0
        for <linux-mm@kvack.org>; Mon, 07 Dec 2015 08:21:05 -0800 (PST)
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com. [74.125.82.45])
        by mx.google.com with ESMTPS id j10si33726997wje.70.2015.12.07.08.21.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Dec 2015 08:21:04 -0800 (PST)
Received: by wmec201 with SMTP id c201so157831872wme.1
        for <linux-mm@kvack.org>; Mon, 07 Dec 2015 08:21:04 -0800 (PST)
Date: Mon, 7 Dec 2015 17:21:03 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/memcontrol.c: use list_{first,next}_entry
Message-ID: <20151207162102.GC20774@dhcp22.suse.cz>
References: <9e62e3006561653fcbf0c49cf0b9c2b653a8ed0e.1449152124.git.geliangtang@163.com>
 <20151203162718.GK9264@dhcp22.suse.cz>
 <20151205025542.GB9812@bogon>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151205025542.GB9812@bogon>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geliang Tang <geliangtang@163.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat 05-12-15 10:55:42, Geliang Tang wrote:
> On Thu, Dec 03, 2015 at 05:27:18PM +0100, Michal Hocko wrote:
> > On Thu 03-12-15 22:16:55, Geliang Tang wrote:
> > > To make the intention clearer, use list_{first,next}_entry instead
> > > of list_entry.
> > 
> > Does this really help readability? This function simply uncharges the
> > given list of pages. Why cannot we simply use list_for_each_entry
> > instead...
> 
> I have tested it, list_for_each_entry can't work. Dose it mean that my
> patch is OK? Or please give me some other advices.

I dunno. Your change is technically correct of course. I find the exit
condition easier to read without your patch though.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
