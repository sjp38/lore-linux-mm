Content-Type: text/plain; charset="us-ascii"
Date: Wed, 22 Aug 2007 06:10:50 +0200
From: "Michael Kerrisk" <mtk-manpages@gmx.net>
In-Reply-To: <1187711147.5066.13.camel@localhost>
Message-ID: <20070822041050.158210@gmx.net>
MIME-Version: 1.0
References: <1180467234.5067.52.camel@localhost>	
 <Pine.LNX.4.64.0705291247001.26308@schroedinger.engr.sgi.com>	
 <200705292216.31102.ak@suse.de> <1180541849.5850.30.camel@localhost>	
 <20070531082016.19080@gmx.net> <1180732544.5278.158.camel@localhost>	
 <46A44B98.8060807@gmx.net> <46AB0CDB.8090600@gmx.net>	
 <20070816200520.GB16680@bingen.suse.de>  <20070818055026.265030@gmx.net>
 <1187711147.5066.13.camel@localhost>
Subject: Re: get_mempolicy.2 man page patch
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: clameter@sgi.com, akpm@linux-foundation.org, linux-mm@kvack.org, ak@suse.de
List-ID: <linux-mm.kvack.org>

> > Lee, for each of th changed pages, could you write me a short summary
> > of the changes, suitable for inclusion in the change log?
> 
> Michael:
> 
> The terse and generic description re:  adding missing semantics and
> error returns to match kernel code is not sufficient?

Too terse ;-).

Perhaps you could briefly list which descriptions of semantics
were added?

> What level of detail would be?
> 
> I have rebased the patch against the 2.64 man pages if you'd like me to
> send that along.  There were a few conflicts, as you or someone had
> moved some text around.

That would be great.

Cheers,

Michael
-- 
Michael Kerrisk
maintainer of Linux man pages Sections 2, 3, 4, 5, and 7 

Want to help with man page maintenance?  
Grab the latest tarball at
http://www.kernel.org/pub/linux/docs/manpages , 
read the HOWTOHELP file and grep the source 
files for 'FIXME'.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
