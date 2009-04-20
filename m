Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1CA0B5F0001
	for <linux-mm@kvack.org>; Mon, 20 Apr 2009 12:15:25 -0400 (EDT)
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e7.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n3KG5BAT005624
	for <linux-mm@kvack.org>; Mon, 20 Apr 2009 12:05:11 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n3KGFRVw181664
	for <linux-mm@kvack.org>; Mon, 20 Apr 2009 12:15:27 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n3KGDetn005205
	for <linux-mm@kvack.org>; Mon, 20 Apr 2009 12:13:42 -0400
Subject: Re: [PATCH V3] Fix Committed_AS underflow
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <1240218590-16714-1-git-send-email-ebmunson@us.ibm.com>
References: <1240218590-16714-1-git-send-email-ebmunson@us.ibm.com>
Content-Type: text/plain
Date: Mon, 20 Apr 2009 09:15:20 -0700
Message-Id: <1240244120.32604.278.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Eric B Munson <ebmunson@us.ibm.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mel@linux.vnet.ibm.com, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Mon, 2009-04-20 at 10:09 +0100, Eric B Munson wrote:
> 1. Change NR_CPUS to min(64, NR_CPUS)
>    This will limit the amount of possible skew on kernels compiled for very
>    large SMP machines.  64 is an arbitrary number selected to limit the worst
>    of the skew without using more cache lines.  min(64, NR_CPUS) is used
>    instead of nr_online_cpus() because nr_online_cpus() requires a shared
>    cache line and a call to hweight to make the calculation.  Its runtime
>    overhead and keeping this counter accurate showed up in profiles and it's
>    possible that nr_online_cpus() would also show.



-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
