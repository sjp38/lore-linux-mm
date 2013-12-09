Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 07F8F6B003A
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 04:14:04 -0500 (EST)
Received: by mail-pd0-f174.google.com with SMTP id y13so4836988pdi.19
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 01:14:04 -0800 (PST)
Received: from e23smtp08.au.ibm.com (e23smtp08.au.ibm.com. [202.81.31.141])
        by mx.google.com with ESMTPS id cz3si1188748pbc.303.2013.12.09.01.14.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 09 Dec 2013 01:14:03 -0800 (PST)
Received: from /spool/local
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Mon, 9 Dec 2013 19:13:59 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 245812CE8052
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 20:13:57 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rB99Di1r4456942
	for <linux-mm@kvack.org>; Mon, 9 Dec 2013 20:13:44 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rB99Duwq016888
	for <linux-mm@kvack.org>; Mon, 9 Dec 2013 20:13:56 +1100
Date: Mon, 9 Dec 2013 17:13:54 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH 13/18] mm: numa: Make NUMA-migrate related functions
 static
Message-ID: <52a589db.a3b2440a.79bc.ffffe030SMTPIN_ADDED_BROKEN@mx.google.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1386572952-1191-1-git-send-email-mgorman@suse.de>
 <1386572952-1191-14-git-send-email-mgorman@suse.de>
 <20131209072010.GA3716@hacker.(null)>
 <20131209084659.GX11295@suse.de>
 <20131209085720.GA16251@hacker.(null)>
 <20131209090833.GY11295@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131209090833.GY11295@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alex Thorlton <athorlton@sgi.com>, Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Dec 09, 2013 at 09:08:34AM +0000, Mel Gorman wrote:
>On Mon, Dec 09, 2013 at 04:57:20PM +0800, Wanpeng Li wrote:
>> On Mon, Dec 09, 2013 at 08:46:59AM +0000, Mel Gorman wrote:
>> >On Mon, Dec 09, 2013 at 03:20:10PM +0800, Wanpeng Li wrote:
>> >> Hi Mel,
>> >> On Mon, Dec 09, 2013 at 07:09:07AM +0000, Mel Gorman wrote:
>> >> >numamigrate_update_ratelimit and numamigrate_isolate_page only have callers
>> >> >in mm/migrate.c. This patch makes them static.
>> >> >
>> >> 
>> >> I have already send out patches to fix this issue yesterday. ;-)
>> >> 
>> >> http://marc.info/?l=linux-mm&m=138648332222847&w=2
>> >> http://marc.info/?l=linux-mm&m=138648332422848&w=2
>> >> 
>> >
>> >I know. I had written the patch some time ago waiting to go out with
>> >the TLB flush fix and just didn't bother dropping it in response to your
>> >series.
>> 
>> Ok, could you review my patchset v3? Thanks in advance. ;-)
>> 
>
>Glanced through it this morning and saw nothing wrong. I expect it'll
>get picked up in due course.

Thanks Mel. ;-)

Regards,
Wanpeng Li 

>
>Thanks
>
>-- 
>Mel Gorman
>SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
