Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 8EB136B0005
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 21:53:02 -0400 (EDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Mon, 8 Apr 2013 21:53:01 -0400
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id B6CAFC9001D
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 21:52:58 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r391qw5h57081952
	for <linux-mm@kvack.org>; Mon, 8 Apr 2013 21:52:58 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r391qv7x019827
	for <linux-mm@kvack.org>; Mon, 8 Apr 2013 21:52:58 -0400
Message-ID: <51637470.5030906@linux.vnet.ibm.com>
Date: Mon, 08 Apr 2013 18:52:48 -0700
From: Cody P Schafer <cody@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] mm/page_alloc: convert zone_pcp_update() to use on_each_cpu()
 instead of stop_machine()
References: <1365194030-28939-1-git-send-email-cody@linux.vnet.ibm.com> <1365194030-28939-3-git-send-email-cody@linux.vnet.ibm.com> <5161931A.8060501@gmail.com> <5162FF18.8010802@linux.vnet.ibm.com> <516319FF.6030104@gmail.com> <51631F4D.7050504@linux.vnet.ibm.com> <5163424A.4000106@gmail.com>
In-Reply-To: <5163424A.4000106@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 04/08/2013 03:18 PM, KOSAKI Motohiro wrote:
> (4/8/13 3:49 PM), Cody P Schafer wrote:>
>> If this turns out to be an issue, schedule_on_each_cpu() could be an
>> alternative.
>
> no way. schedule_on_each_cpu() is more problematic and it should be removed
> in the future.
> schedule_on_each_cpu() can only be used when caller task don't have any lock.
> otherwise it may make deadlock.

I wasn't aware of that. Just to be clear, the deadlock you're referring 
to isn't the same one refered to in

commit b71ab8c2025caef8db719aa41af0ed735dc543cd
Author: Tejun Heo <tj@kernel.org>
Date:   Tue Jun 29 10:07:14 2010 +0200
workqueue: increase max_active of keventd and kill current_is_keventd()

and

commit 65a64464349883891e21e74af16c05d6e1eeb4e9
Author: Andi Kleen <ak@linux.intel.com>
Date:   Wed Oct 14 06:22:47 2009 +0200
HWPOISON: Allow schedule_on_each_cpu() from keventd

If you're referencing some other deadlock, could you please provide a 
link to the relevant discussion? (I'd really like to add a note to 
schedule_on_each_cpu()'s doc comment about it so others can avoid that 
pitfall).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
