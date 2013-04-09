Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id E9F086B0006
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 06:14:39 -0400 (EDT)
Date: Tue, 9 Apr 2013 12:14:37 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm: page_alloc: Avoid marking zones full prematurely
 after zone_reclaim()
Message-ID: <20130409101437.GE29860@dhcp22.suse.cz>
References: <20130320181957.GA1878@suse.de>
 <514A7163.5070700@gmail.com>
 <20130321081902.GD6094@dhcp22.suse.cz>
 <515E6FC4.5000202@gmail.com>
 <5163E7EA.1040608@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5163E7EA.1040608@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Hedi Berriche <hedi@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 09-04-13 18:05:30, Simon Jeons wrote:
[...]
> >I try this in v3.9-rc5:
> >dd if=/dev/sda of=/dev/null bs=1MB
> >14813+0 records in
> >14812+0 records out
> >14812000000 bytes (15 GB) copied, 105.988 s, 140 MB/s
> >
> >free -m -s 1
> >
> >                   total       used       free     shared buffers
> >cached
> >Mem:          7912       1181       6731          0 663        239
> >-/+ buffers/cache:        277       7634
> >Swap:         8011          0       8011
> >
> >It seems that almost 15GB copied before I stop dd, but the used
> >pages which I monitor during dd always around 1200MB. Weird, why?
> >
> 
> Sorry for waste your time, but the test result is weird, is it?

I am not sure which values you have been watching but you have to
realize that you are reading a _partition_ not a file and those pages
go into buffers rather than the page chache.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
