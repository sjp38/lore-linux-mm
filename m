Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j5MGNQ1N554654
	for <linux-mm@kvack.org>; Wed, 22 Jun 2005 12:23:26 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j5MGNP8X181432
	for <linux-mm@kvack.org>; Wed, 22 Jun 2005 10:23:25 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j5MGNPa6019239
	for <linux-mm@kvack.org>; Wed, 22 Jun 2005 10:23:25 -0600
Subject: Re: 2.6.12-mm1 & 2K lun testing  (JFS problem ?)
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <20050622014121.GB10690@holomorphy.com>
References: <1118856977.4301.406.camel@dyn9047017072.beaverton.ibm.com>
	 <20050616002451.01f7e9ed.akpm@osdl.org>
	 <1118951458.4301.478.camel@dyn9047017072.beaverton.ibm.com>
	 <20050616133730.1924fca3.akpm@osdl.org>
	 <1118965381.4301.488.camel@dyn9047017072.beaverton.ibm.com>
	 <20050616175130.22572451.akpm@osdl.org> <42B2E7D2.9080705@us.ibm.com>
	 <20050617141331.078e5f8f.akpm@osdl.org>
	 <1119400494.4620.33.camel@dyn9047017102.beaverton.ibm.com>
	 <20050622014121.GB10690@holomorphy.com>
Content-Type: text/plain
Date: Wed, 22 Jun 2005 09:23:23 -0700
Message-Id: <1119457404.11299.8.camel@dyn9047017102.beaverton.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Andrew Morton <akpm@osdl.org>, shaggy@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Wli,

Okay. Let me go through all the tests one more time with collecting
data. I will compare raw vs filesystem writes with dirty ratio
tuning. I will provide vmstat, slabinfo, meminfo, profile data
for each of those. You need anything else ?

BTW, I will send the data offline. I don't want to polute the
list with megabytes of data.

Thanks,
Badari

On Tue, 2005-06-21 at 18:41 -0700, William Lee Irwin III wrote:
> On Tue, Jun 21, 2005 at 05:34:54PM -0700, Badari Pulavarty wrote:
> > Hi Andrew & Shaggy,
> > Here is the summary of 2K lun testing on 2.6.12-mm1.
> > When I tune dirty ratios and CFQ queue depths, things
> > seems to be running fine.
> > 	echo 20 > /proc/sys/vm/dirty_ratio
> > 	echo 20 > /proc/sys/vm/overcommit_ratio
> > 	echo 4 > /sys/block/<device>/queue/nr_requests
> > But, I am running into JFS problem. I can't kill my
> > "dd" process. They all get stuck in:
> > (I am going to try ext3).
> 
> If you could get unabridged profiling data for raw vs. fs (so it can
> be properly sorted) I would be interested in that. Early indications
> were large amounts of time spent in shrink_zone(), obtained by
> re-sorting the truncated profile listings. It indicated the time spent
> in shrink_zone() was 26.3 times as much time spent in default_idle().
> Typically copying to and from userspace are enormous overheads, but
> aren't observable in the truncated/mis-sorted profiles, which calls
> them into question, barring unreported usage of O_DIRECT. There are
> also no totals reported, which are helpful for interpreting realtime
> behavior.
> 
> 
> -- wli
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
