Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 031826B003D
	for <linux-mm@kvack.org>; Thu, 30 Apr 2009 17:15:44 -0400 (EDT)
Date: Thu, 30 Apr 2009 14:10:41 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] use GFP_NOFS in kernel_event()
Message-Id: <20090430141041.c167b4d4.akpm@linux-foundation.org>
In-Reply-To: <1241097573.6020.7.camel@localhost.localdomain>
References: <20090430020004.GA1898@localhost>
	<20090429191044.b6fceae2.akpm@linux-foundation.org>
	<1241097573.6020.7.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Eric Paris <eparis@redhat.com>
Cc: fengguang.wu@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mpm@selenic.com, clameter@sgi.com, mingo@elte.hu, viro@zeniv.linux.org.uk
List-ID: <linux-mm.kvack.org>

On Thu, 30 Apr 2009 09:19:33 -0400
Eric Paris <eparis@redhat.com> wrote:

> > Somebody was going to fix this for us via lockdep annotation.
> > 
> > <adds randomly-chosen cc>
> 
> I really didn't forget this, but I can't figure out how to recreate it,
> so I don't know if my logic in the patch is sound.  The patch certainly
> will shut up the complaint.

Do you think we should merge the GFP_NOFS workaround for 2.6.30 and
fix all up nicely for 2.6.31?

GFP_NOFS isn't all that bad, really - it will work sufficiently well. 
Being able to switch it over to GFP_KERNEL later on is a pretty minor
optimisation.  But it would be bad of us to simply forget about it, so I'd
probably end up retaining a switch-back-to-GFP_KERNEL patch in -mm with
which to periodically harrass you guys ;)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
