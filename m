Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id ED3616B0023
	for <linux-mm@kvack.org>; Wed, 14 Sep 2011 11:48:57 -0400 (EDT)
Received: by bkbzs2 with SMTP id zs2so2159409bkb.14
        for <linux-mm@kvack.org>; Wed, 14 Sep 2011 08:48:54 -0700 (PDT)
Date: Wed, 14 Sep 2011 19:48:26 +0400
From: Vasiliy Kulikov <segoon@openwall.com>
Subject: Re: [kernel-hardening] Re: [RFC PATCH 2/2] mm: restrict access to
 /proc/slabinfo
Message-ID: <20110914154826.GA9942@albatros>
References: <20110910164001.GA2342@albatros>
 <20110910164134.GA2442@albatros>
 <20110914131630.GA7001@albatros>
 <1316013505.4478.50.camel@nimitz>
 <20110914154229.GA9776@albatros>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110914154229.GA9776@albatros>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel-hardening@lists.openwall.com, Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Cyrill Gorcunov <gorcunov@gmail.com>, Al Viro <viro@zeniv.linux.org.uk>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dan Rosenberg <drosenberg@vsecurity.com>, Theodore Tso <tytso@mit.edu>, Alan Cox <alan@linux.intel.com>, Jesper Juhl <jj@chaosbits.net>, Linus Torvalds <torvalds@linux-foundation.org>

(cc'ed Dave back, sorry for the noise)

On Wed, Sep 14, 2011 at 19:42 +0400, Vasiliy Kulikov wrote:
> Hi Dave,
> 
> On Wed, Sep 14, 2011 at 08:18 -0700, Dave Hansen wrote:
> > On Wed, 2011-09-14 at 17:16 +0400, Vasiliy Kulikov wrote:
> > > > World readable slabinfo simplifies kernel developers' job of debugging
> > > > kernel bugs (e.g. memleaks), but I believe it does more harm than
> > > > benefits.  For most users 0444 slabinfo is an unreasonable attack vector.
> > > 
> > > Please tell if anybody has complains about the restriction - whether it
> > > forces someone besides kernel developers to do "chmod/chgrp".  But if
> > > someone want to debug the kernel, it shouldn't significantly influence
> > > on common users, especially it shouldn't create security issues. 
> > 
> > Ubuntu ships today with a /etc/init/mounted-proc.conf that does:
> > 
> > 	chmod 0400 "${MOUNTPOINT}"/slabinfo
> > 
> > After cursing Kees's name a few times, I commented it out and it hasn't
> > bothered me again.  
> 
> Another way is chgrp slabinfo to some "admin" group which are privileged
> in this sense and add your user to this group.  But please, sane and
> secure defaults!
> 
> > I expect that the folks that really care about this (and their distros)
> > will probably have a similar mechanism.  I guess the sword cuts both
> > ways in this case: it obviously _works_ to have the distros do it, but
> > it was a one-time inconvenience for me to override that.
> > 
> > In other words, I dunno.  If we do this in the kernel, can we at least
> > do something like CONFIG_INSECURE to both track these kinds of things
> > and make it easy to get them out of a developer's way?
> 
> What do you think about adding your user to the slabinfo's group or
> chmod it - quite the opposite Ubuntu currently does?  I think it is more
> generic (e.g. you may chmod 0444 to allow all users to get debug
> information or just 0440 and chgrp admin to allow only trusted users to
> do it) and your local policy doesn't touch the kernel.
> 
> Thanks,
> 
> -- 
> Vasiliy Kulikov
> http://www.openwall.com - bringing security into open computing environments

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
