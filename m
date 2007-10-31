Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9VKg5r7029517
	for <linux-mm@kvack.org>; Wed, 31 Oct 2007 16:42:05 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9VKg5DI124524
	for <linux-mm@kvack.org>; Wed, 31 Oct 2007 14:42:05 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9VKg4Vo017151
	for <linux-mm@kvack.org>; Wed, 31 Oct 2007 14:42:04 -0600
Subject: Re: [PATCH 1/3] Add remove_memory() for ppc64
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <46434BBD-7656-41B1-BED0-3A3E212032B5@kernel.crashing.org>
References: <1193849375.17412.34.camel@dyn9047017100.beaverton.ibm.com>
	 <46434BBD-7656-41B1-BED0-3A3E212032B5@kernel.crashing.org>
Content-Type: text/plain
Date: Wed, 31 Oct 2007 13:45:33 -0800
Message-Id: <1193867133.17412.49.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kumar Gala <galak@kernel.crashing.org>
Cc: Paul Mackerras <paulus@samba.org>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@ozlabs.org, anton@au1.ibm.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2007-11-01 at 01:26 -0500, Kumar Gala wrote:
> On Oct 31, 2007, at 11:49 AM, Badari Pulavarty wrote:
> 
> > Supply arch specific remove_memory() for PPC64. There is nothing
> > ppc specific code here and its exactly same as ia64 version.
> > For now, lets keep it arch specific - so each arch can add
> > its own special things if needed.
> >
> > Signed-off-by: Badari Pulavarty <pbadari@us.ibm.com>
> > ---
> 
> What's ppc64 specific about these patches?

Like I mentioned, nothing. When KAME did the hotplug memory
remove, he kept this remove_memory() arch-specific - so
each arch can provide its own, if it needs to something
special. So far, there is no need for arch-specific 
remove_memory(). If other archs (x86-64 and others)
agree we can merge this into arch neutral code.

I have to provide this for ppc64 to plug into general
frame work.

Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
