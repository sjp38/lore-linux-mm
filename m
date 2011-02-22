Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 66C8C8D0039
	for <linux-mm@kvack.org>; Tue, 22 Feb 2011 11:36:36 -0500 (EST)
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e37.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p1MGXsHp021714
	for <linux-mm@kvack.org>; Tue, 22 Feb 2011 09:33:54 -0700
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p1MGaSOT108572
	for <linux-mm@kvack.org>; Tue, 22 Feb 2011 09:36:28 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p1MGaRJ7003170
	for <linux-mm@kvack.org>; Tue, 22 Feb 2011 09:36:28 -0700
Subject: Re: [PATCH 8/8] Add VM counters for transparent hugepages
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <1298315270-10434-9-git-send-email-andi@firstfloor.org>
References: <1298315270-10434-1-git-send-email-andi@firstfloor.org>
	 <1298315270-10434-9-git-send-email-andi@firstfloor.org>
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Date: Tue, 22 Feb 2011 08:36:26 -0800
Message-ID: <1298392586.9829.22566.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, aarcange@redhat.com, lwoodman@redhat.com, Andi Kleen <ak@linux.intel.com>

On Mon, 2011-02-21 at 11:07 -0800, Andi Kleen wrote:
> From: Andi Kleen <ak@linux.intel.com>
> 
> I found it difficult to make sense of transparent huge pages without
> having any counters for its actions. Add some counters to vmstat
> for allocation of transparent hugepages and fallback to smaller
> pages.
> 
> Optional patch, but useful for development and understanding the system.

Very nice.  I did the same thing, splits-only.  I also found this stuff
a must-have for trying to do any work with transparent hugepages.  It's
just impossible otherwise.

Acked-by: Dave Hansen <dave@linux.vnet.ibm.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
