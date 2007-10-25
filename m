Date: Thu, 25 Oct 2007 16:21:18 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 0/2] Export memblock migrate type to /sysfs
Message-Id: <20071025162118.bb24aa4b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <472020C8.4090007@us.ibm.com>
References: <1193243860.30836.22.camel@dyn9047017100.beaverton.ibm.com>
	<20071025093531.d2357422.kamezawa.hiroyu@jp.fujitsu.com>
	<472020C8.4090007@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari <pbadari@us.ibm.com>
Cc: melgor@ie.ibm.com, haveblue@us.ibm.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 24 Oct 2007 21:51:20 -0700
Badari <pbadari@us.ibm.com> wrote:
> > How about showing information as following ?
> > ==
> > %cat ./memory/memory0/mem_type
> >  1 0 0 0 0
> > %
> > as 
> >  Reserved Unmovable Movable Reserve Isolate
> >
> >   
> Personally, I have no problem. But its against the rules of /sysfs - 
> "one value per file" rule :(
> I would say, lets keep it simple for now and extend it if needed.
> 
Hmm, but misleading information is not good.

How about adding "Mixed" status for memory section which containes multiple
page types ? For memory hotplug, it's enough.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
