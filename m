Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id E27E08D0001
	for <linux-mm@kvack.org>; Tue,  2 Nov 2010 15:40:00 -0400 (EDT)
Received: from wpaz13.hot.corp.google.com (wpaz13.hot.corp.google.com [172.24.198.77])
	by smtp-out.google.com with ESMTP id oA2JdvA1030953
	for <linux-mm@kvack.org>; Tue, 2 Nov 2010 12:39:57 -0700
Received: from pwi5 (pwi5.prod.google.com [10.241.219.5])
	by wpaz13.hot.corp.google.com with ESMTP id oA2JdZuk002209
	for <linux-mm@kvack.org>; Tue, 2 Nov 2010 12:39:55 -0700
Received: by pwi5 with SMTP id 5so5717675pwi.25
        for <linux-mm@kvack.org>; Tue, 02 Nov 2010 12:39:55 -0700 (PDT)
Date: Tue, 2 Nov 2010 12:39:52 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] Add Kconfig option for default swappiness
In-Reply-To: <87oca7evbo.fsf@gmail.com>
Message-ID: <alpine.DEB.2.00.1011021235130.21387@chino.kir.corp.google.com>
References: <1288668052-32036-1-git-send-email-bgamari.foss@gmail.com> <alpine.DEB.2.00.1011012030100.12298@chino.kir.corp.google.com> <87oca7evbo.fsf@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Ben Gamari <bgamari.foss@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jesper Juhl <jj@chaosbits.net>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2 Nov 2010, Ben Gamari wrote:

> > And they can't use an init script to tune /proc/sys/vm/swappiness 
> > because...?
> 
> Packaging concerns, as I mentioned before,
> 

That you snipped from the changelog?

> On Mon, Nov 01, 2010 at 08:52:30AM -0400, Ben Gamari wrote:
> > Ubuntu ships different kernels for desktop and server usage. From a
> > packaging standpoint it would be much nicer to have this set in the
> > kernel configuration. If we were to throw the setting /etc/sysctl.conf
> > the kernel would depend upon the package containing sysctl(8)
> > (procps). We'd rather avoid this and keep the default kernel
> > configuration in one place.
> 
> In short, being able to specify this default in .config is just far
> simpler from a packaging standpoint than the alternatives.
> 

You could say the same thing for any sysctl, it's not indicative of why 
this particular change is needed in the kernel.

Let's not have the "in short" answer, what's the "long" answer?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
