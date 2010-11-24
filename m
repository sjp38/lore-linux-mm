Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id D618D6B0071
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 14:13:57 -0500 (EST)
Date: Wed, 24 Nov 2010 11:13:43 -0800
From: Andres Salomon <dilinger@queued.net>
Subject: Re: mmotm 2010-11-23-16-12 uploaded (olpc)
Message-ID: <20101124111343.70019b5c@debxo>
In-Reply-To: <20101124105126.8248fc1f.randy.dunlap@oracle.com>
References: <201011240045.oAO0jYQ5016010@imap1.linux-foundation.org>
	<20101124105126.8248fc1f.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Randy Dunlap <randy.dunlap@oracle.com>
Cc: akpm@linux-foundation.org, Daniel Drake <dsd@laptop.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 24 Nov 2010 10:51:26 -0800
Randy Dunlap <randy.dunlap@oracle.com> wrote:

> On Tue, 23 Nov 2010 16:13:06 -0800 akpm@linux-foundation.org wrote:
> 
> > The mm-of-the-moment snapshot 2010-11-23-16-12 has been uploaded to
> > 
> >    http://userweb.kernel.org/~akpm/mmotm/
> > 
> > and will soon be available at
> > 
> >    git://zen-kernel.org/kernel/mmotm.git=
> 
> 
> make[4]: *** No rule to make target
> `arch/x86/platform/olpc/olpc-xo1-wakeup.c', needed by
> `arch/x86/platform/olpc/olpc-xo1-wakeup.o'.
> 
> 
> It's olpc-xo1-wakeup.S, so I guess it needs a special makefile rule ??
> 

I had trouble with this as well (and after flailing at it a bit, ended
up just dropping the olpc pm stuff from my tree for now).  The build
failure is definitely config-specific.  I suspected that it needs
something like the following, but failed to figure it out:

foo-y := olpc-xo1-wakeup.o
obj-$(CONFIG_OLPC_XO1) += olpc-xo1.o foo.o


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
