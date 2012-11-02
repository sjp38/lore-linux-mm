Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 2E50B6B0044
	for <linux-mm@kvack.org>; Fri,  2 Nov 2012 12:14:52 -0400 (EDT)
Received: by mail-vb0-f41.google.com with SMTP id v13so4899153vbk.14
        for <linux-mm@kvack.org>; Fri, 02 Nov 2012 09:14:50 -0700 (PDT)
Date: Fri, 2 Nov 2012 12:14:47 -0400
From: Konrad Rzeszutek Wilk <konrad@kernel.org>
Subject: Re: [RFC] mm: add support for zsmalloc and zcache
Message-ID: <20121102161444.GB4633@konrad-lan.dumpdata.com>
References: <20120921180222.GA7220@phenom.dumpdata.com>
 <505CB9BC.8040905@linux.vnet.ibm.com>
 <42d62a30-bd6c-4bd7-97d1-bec2f237756b@default>
 <50609794.8030508@linux.vnet.ibm.com>
 <b34c65c9-4b25-431d-8b82-cbe911126be9@default>
 <5064B647.3000906@linux.vnet.ibm.com>
 <76d1a3f1-efc5-48b5-b485-604a94adcc1d@default>
 <506B2C4B.3080508@linux.vnet.ibm.com>
 <771b722f-3036-451a-a416-e6ab5b4a05f7@default>
 <508B046A.6050006@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <508B046A.6050006@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Wilk <konrad.wilk@oracle.com>, Mel Gorman <mgorman@suse.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org, James Bottomley <James.Bottomley@HansenPartnership.com>

On Fri, Oct 26, 2012 at 04:45:14PM -0500, Seth Jennings wrote:
> On 10/02/2012 01:17 PM, Dan Magenheimer wrote:
> > If so, <shake hands> and move forward?  What do you see as next steps?
> 
> I've been reviewing the changes between zcache and zcache2 and getting
> a feel for the scope and direction of those changes.
> 
> - Getting the community engaged to review zcache1 at ~2300SLOC was
>   difficult.
> - Adding RAMSter has meant adding RAMSter-specific code broadly across
>   zcache and increases the size of code to review to ~7600SLOC.

One can ignore the drivers/staging/ramster/ramster* directory.

> - The changes have blurred zcache's internal layering and increased
>   complexity beyond what a simple SLOC metric can reflect.

Not sure I see a problem.
> - Getting the community engaged in reviewing zcache2 will be difficult
>   and will require an exceptional amount of effort for maintainer and
>   reviewer.

Exceptional? I think if we start trimming the code down and moving it
around - and moving the 'ramster' specific calls to header files to
not be compiled - that should make it easier to read.

I mean the goal of any review is to address all of the concern you saw
when you were looking over the code. You probably have a page of
questions you asked yourself - and in all likehood the other reviewers
would ask the same questions. So if you address them - either by
giving comments or making the code easier to read - that would do it.

> 
> It is difficult for me to know when it could be ready for mainline and
> production use.  While zcache2 isn't getting broad code reviews yet,
> how do suggest managing that complexity to make the code maintainable
> and get it reviewed?

There are Mel's feedback that is also applicable to zcache2.

Thanks for looking at the code!
> 
> Seth
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
