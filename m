Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9PHFWgf002858
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 13:15:32 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9PHFV2Z136674
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 13:15:31 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9PHFUoK028404
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 13:15:31 -0400
Subject: Re: [PATCH 2/2] Add mem_type in /syfs to show memblock migrate type
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <1193332042.9894.10.camel@dyn9047017100.beaverton.ibm.com>
References: <1193327756.9894.5.camel@dyn9047017100.beaverton.ibm.com>
	 <1193331162.4039.141.camel@localhost>
	 <1193332042.9894.10.camel@dyn9047017100.beaverton.ibm.com>
Content-Type: text/plain
Date: Thu, 25 Oct 2007 10:15:28 -0700
Message-Id: <1193332528.4039.156.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, melgor@ie.ibm.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2007-10-25 at 10:07 -0700, Badari Pulavarty wrote:
> I agree with you that all I care about are the "movable" sections 
> for remove. But what we are doing here is, exporting the migrate type
> to user-space and let the user space make a decision on what type
> of sections to use for its use. For now, we can migrate/remove ONLY
> "movable" sections. But in the future, we may be able to
> migrate/remove
> "Reclaimable" ones. I don't know.

Right, and if that happens, we simply update the one function that makes
the (non)removable decision.

> I don't want to make decisions in the kernel for removability

Too late. :)  That's what the mobility patches are all about: having the
kernel make decisions that affect removability.  

>  - as
> it might change depending on the situation. All I want is to export
> the info and let user-space deal with the decision making.

That's a good point.  But, if we have multiple _removable_ pageblocks in
the same section, but with slightly different types, your patch doesn't
help.  The user will just see "Multiple", and won't be able to tell that
they can remove it. :(

The sysfs entries are basically only exposed for memory hotplug, and I
don't think exposing the mobility stuff itself there has many valid
uses.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
