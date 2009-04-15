Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 26BC45F0001
	for <linux-mm@kvack.org>; Wed, 15 Apr 2009 18:55:53 -0400 (EDT)
Date: Wed, 15 Apr 2009 15:50:58 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 4/4] add ksm kernel shared memory driver.
Message-Id: <20090415155058.9e4635b2.akpm@linux-foundation.org>
In-Reply-To: <49E661A5.8050305@redhat.com>
References: <1239249521-5013-1-git-send-email-ieidus@redhat.com>
	<1239249521-5013-2-git-send-email-ieidus@redhat.com>
	<1239249521-5013-3-git-send-email-ieidus@redhat.com>
	<1239249521-5013-4-git-send-email-ieidus@redhat.com>
	<1239249521-5013-5-git-send-email-ieidus@redhat.com>
	<20090414150929.174a9b25.akpm@linux-foundation.org>
	<49E661A5.8050305@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Izik Eidus <ieidus@redhat.com>
Cc: linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm@kvack.org, avi@redhat.com, aarcange@redhat.com, chrisw@redhat.com, mtosatti@redhat.com, hugh@veritas.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Thu, 16 Apr 2009 01:37:25 +0300
Izik Eidus <ieidus@redhat.com> wrote:

> Andrew Morton wrote:
> > On Thu,  9 Apr 2009 06:58:41 +0300
> > Izik Eidus <ieidus@redhat.com> wrote:
> >
> >   
> >
> > Confused.  In the covering email you indicated that v2 of the patchset
> > had abandoned ioctls and had moved the interface to sysfs.
> >   
> We have abandoned the ioctls that control the ksm behavior (how much cpu 
> it take, how much kernel pages it may allocate and so on...)
> But we still use ioctls to register the application memory to be used 
> with ksm.

hm. ioctls make kernel people weep and gnash teeth.

An appropriate interface would be to add new syscalls.  But as ksm is
an optional thing and can even be modprobed, that doesn't work.  And
having a driver in mm/ which can be modprobed is kinda neat.

I can't immediately think of a nicer interface.  You could always poke
numbers into some pseudo-file but to me that seems as ugly, or uglier
than an ioctl (others seem to disagee).

Ho hum.  Please design the ioctl interface so that it doesn't need any
compat handling if poss.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
