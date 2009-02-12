Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id C62A06B0095
	for <linux-mm@kvack.org>; Thu, 12 Feb 2009 18:13:59 -0500 (EST)
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e8.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n1CN75J1026668
	for <linux-mm@kvack.org>; Thu, 12 Feb 2009 18:07:05 -0500
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n1CNDvh2172530
	for <linux-mm@kvack.org>; Thu, 12 Feb 2009 18:13:57 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n1CNDuww028796
	for <linux-mm@kvack.org>; Thu, 12 Feb 2009 18:13:57 -0500
Subject: Re: [RFC v13][PATCH 00/14] Kernel based checkpoint/restart
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <1234479924.3152.13.camel@calx>
References: <1233076092-8660-1-git-send-email-orenl@cs.columbia.edu>
	 <1234285547.30155.6.camel@nimitz>
	 <20090211141434.dfa1d079.akpm@linux-foundation.org>
	 <1234462282.30155.171.camel@nimitz>  <1234467035.3243.538.camel@calx>
	 <1234479457.30155.214.camel@nimitz>  <1234479924.3152.13.camel@calx>
Content-Type: text/plain
Date: Thu, 12 Feb 2009 15:13:53 -0800
Message-Id: <1234480433.30155.226.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Matt Mackall <mpm@selenic.com>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, orenl@cs.columbia.edu, linux-api@vger.kernel.org, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, viro@zeniv.linux.org.uk, hpa@zytor.com, Thomas Gleixner <tglx@linutronix.de>, Cedric Le Goater <clg@fr.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Alexey Dobriyan <adobriyan@gmail.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2009-02-12 at 17:05 -0600, Matt Mackall wrote:
> On Thu, 2009-02-12 at 14:57 -0800, Dave Hansen wrote:
> > > Also, what happens if I checkpoint a process in 2.6.30 and restore it in
> > > 2.6.31 which has an expanded idea of what should be restored? Do your
> > > file formats handle this sort of forward compatibility or am I
> > > restricted to one kernel?
> > 
> > In general, you're restricted to one kernel.  But, people have mentioned
> > that, if the formats change, we should be able to write in-userspace
> > converters for the checkpoint files.  
> 
> I mentioned this because it seems like a key use case is upgrading
> kernels out from under long-lived applications.

The key users as I envision it aren't really kernel hackers who are
always running 2.6-next and running radically different kernels from
moment to moment. :)

Distros are pretty picky about changing things internal to the kernel
during errata updates or even service packs.  While that can be a pain
for some of us developers trying to get features and fixes in, it is a
godsend for trying to do something like process migration across an
update.

My random speculation would be that for things that if a kernel upgrade
can be performed with ksplice (http://www.ksplice.com/) -- the original
non-fancy version at least -- we can probably migrate across the
upgrade.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
