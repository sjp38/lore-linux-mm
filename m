Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j5GMnSTg005834
	for <linux-mm@kvack.org>; Thu, 16 Jun 2005 18:49:28 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j5GMnSCk211944
	for <linux-mm@kvack.org>; Thu, 16 Jun 2005 18:49:28 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j5GMnSs5007817
	for <linux-mm@kvack.org>; Thu, 16 Jun 2005 18:49:28 -0400
Subject: Re: 2.6.12-rc6-mm1 & 2K lun testing
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <20050616224230.GD3913@holomorphy.com>
References: <1118856977.4301.406.camel@dyn9047017072.beaverton.ibm.com>
	 <20050616002451.01f7e9ed.akpm@osdl.org>
	 <1118951458.4301.478.camel@dyn9047017072.beaverton.ibm.com>
	 <20050616224230.GD3913@holomorphy.com>
Content-Type: text/plain
Message-Id: <1118960737.4301.483.camel@dyn9047017072.beaverton.ibm.com>
Mime-Version: 1.0
Date: 16 Jun 2005 15:25:42 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Andrew Morton <akpm@osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2005-06-16 at 15:42, William Lee Irwin III wrote:
> On Thu, Jun 16, 2005 at 12:50:59PM -0700, Badari Pulavarty wrote:
> > Yes. I am using CFQ scheduler. I changed nr_requests to 4 for all
> > my devices. I also changed "min_free_kbytes" to 64M.
> > Response time is still bad. Here is the vmstat, meminfo, slabinfo
> > and profle output. I am not sure why profile output shows 
> > default_idle(), when vmstat shows 100% CPU sys.
> 
> It's because you're sorting on the third field of readprofile(1),
> which is pure gibberish. Undoing this mistake will immediately
> enlighten you.

Hmm.. I was under the impression that its gives useful info ..

Here is readprofile man-page says:

       Print the 20 most loaded procedures:
          readprofile | sort -nr +2 | head -20



> Also, turn off slab poisoning when doing performance analyses.

Its already off. I am not trying to compare performance here.
I was trying to analyze VM behaviour with filesystem tests.
(with "raw" devices, machine is perfectly happy - but with
filesystem cache it crawls).

Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
