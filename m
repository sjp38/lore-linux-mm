Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 306C96B0005
	for <linux-mm@kvack.org>; Fri,  1 Feb 2013 10:13:54 -0500 (EST)
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Fri, 1 Feb 2013 08:13:53 -0700
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id E16E319D8043
	for <linux-mm@kvack.org>; Fri,  1 Feb 2013 08:13:49 -0700 (MST)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r11FDatK236826
	for <linux-mm@kvack.org>; Fri, 1 Feb 2013 08:13:37 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r11FDXj6019705
	for <linux-mm@kvack.org>; Fri, 1 Feb 2013 08:13:34 -0700
Message-ID: <510BDB8F.5000104@linux.vnet.ibm.com>
Date: Fri, 01 Feb 2013 09:13:19 -0600
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCHv4 0/7] zswap: compressed swap caching
References: <1359495627-30285-1-git-send-email-sjenning@linux.vnet.ibm.com> <1359682784.3574.2.camel@kernel>
In-Reply-To: <1359682784.3574.2.camel@kernel>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On 01/31/2013 07:39 PM, Simon Jeons wrote:
> Hi Seth,
> On Tue, 2013-01-29 at 15:40 -0600, Seth Jennings wrote:
<snip>
>> Performance, Kernel Building:
>>
>> Setup
>> ========
>> Gentoo w/ kernel v3.7-rc7
>> Quad-core i5-2500 @ 3.3GHz
>> 512MB DDR3 1600MHz (limited with mem=512m on boot)
>> Filesystem and swap on 80GB HDD (about 58MB/s with hdparm -t)
>> majflt are major page faults reported by the time command
>> pswpin/out is the delta of pswpin/out from /proc/vmstat before and after
>> then make -jN
>>
>> Summary
>> ========
>> * Zswap reduces I/O and improves performance at all swap pressure levels.
>>
>> * Under heavy swaping at 24 threads, zswap reduced I/O by 76%, saving
>>   over 1.5GB of I/O, and cut runtime in half.
> 
> How to get your benchmark?

It's just kernel building.  So "make" :)

I intentionally choose this workload so people wouldn't have to jump
through hoops to replicate the results.

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
