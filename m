Subject: Re: 2.5.70-mm9
From: Mingming Cao <cmm@us.ibm.com>
In-Reply-To: <3EEBF2C1.4050101@cyberone.com.au>
References: <20030613013337.1a6789d9.akpm@digeo.com>	<3EEAD41B.2090709@us.ibm.com>
	<20030614010139.2f0f1348.akpm@digeo.com>
	<1055637690.1396.15.camel@w-ming2.beaverton.ibm.com>
	<3EEBF2C1.4050101@cyberone.com.au>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 16 Jun 2003 09:25:32 -0700
Message-Id: <1055780739.23880.439.camel@w-ming.beaverton.ibm.com>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <piggin@cyberone.com.au>
Cc: Andrew Morton <akpm@digeo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 2003-06-14 at 21:14, Nick Piggin wrote:
> 
> 
> Mingming Cao wrote:
> 
> >But the test on elevator=as (2.5.70-mm9 kernel) still failed, same
> >problem.  Some fsx tests are sleeping on io_schedule().  
> >
> 
> So by failed, you just mean stuck in io_schedule? Are you sure
> they are permanently stuck there? Is any progress being made?
> I have tried this test, and often some or most of the processes
> wait in io_schedule for a while, but do get woken.
> 

Yes, I mean they are permanetly hang there with Status D.  No progress
were made.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
