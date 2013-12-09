Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f170.google.com (mail-ob0-f170.google.com [209.85.214.170])
	by kanga.kvack.org (Postfix) with ESMTP id DD0EB6B006E
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 03:57:43 -0500 (EST)
Received: by mail-ob0-f170.google.com with SMTP id wp18so3434950obc.1
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 00:57:43 -0800 (PST)
Received: from e28smtp02.in.ibm.com (e28smtp02.in.ibm.com. [122.248.162.2])
        by mx.google.com with ESMTPS id y1si6669658oec.155.2013.12.09.00.57.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 09 Dec 2013 00:57:42 -0800 (PST)
Received: from /spool/local
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Mon, 9 Dec 2013 14:27:26 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 5C6D61258051
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 14:28:30 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rB98vJF03670304
	for <linux-mm@kvack.org>; Mon, 9 Dec 2013 14:27:19 +0530
Received: from d28av03.in.ibm.com (localhost [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rB98vL3j006046
	for <linux-mm@kvack.org>; Mon, 9 Dec 2013 14:27:21 +0530
Date: Mon, 9 Dec 2013 16:57:20 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH 13/18] mm: numa: Make NUMA-migrate related functions
 static
Message-ID: <52a58606.a10f3c0a.3d5b.12e7SMTPIN_ADDED_BROKEN@mx.google.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1386572952-1191-1-git-send-email-mgorman@suse.de>
 <1386572952-1191-14-git-send-email-mgorman@suse.de>
 <20131209072010.GA3716@hacker.(null)>
 <20131209084659.GX11295@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131209084659.GX11295@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alex Thorlton <athorlton@sgi.com>, Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Dec 09, 2013 at 08:46:59AM +0000, Mel Gorman wrote:
>On Mon, Dec 09, 2013 at 03:20:10PM +0800, Wanpeng Li wrote:
>> Hi Mel,
>> On Mon, Dec 09, 2013 at 07:09:07AM +0000, Mel Gorman wrote:
>> >numamigrate_update_ratelimit and numamigrate_isolate_page only have callers
>> >in mm/migrate.c. This patch makes them static.
>> >
>> 
>> I have already send out patches to fix this issue yesterday. ;-)
>> 
>> http://marc.info/?l=linux-mm&m=138648332222847&w=2
>> http://marc.info/?l=linux-mm&m=138648332422848&w=2
>> 
>
>I know. I had written the patch some time ago waiting to go out with
>the TLB flush fix and just didn't bother dropping it in response to your
>series.

Ok, could you review my patchset v3? Thanks in advance. ;-)

Regards,
Wanpeng Li 

>
>-- 
>Mel Gorman
>SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
