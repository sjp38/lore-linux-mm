Subject: Re: get_mempolicy.2 man page patch
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20070818055026.265030@gmx.net>
References: <1180467234.5067.52.camel@localhost>
	 <Pine.LNX.4.64.0705291247001.26308@schroedinger.engr.sgi.com>
	 <200705292216.31102.ak@suse.de> <1180541849.5850.30.camel@localhost>
	 <20070531082016.19080@gmx.net> <1180732544.5278.158.camel@localhost>
	 <46A44B98.8060807@gmx.net> <46AB0CDB.8090600@gmx.net>
	 <20070816200520.GB16680@bingen.suse.de>  <20070818055026.265030@gmx.net>
Content-Type: text/plain
Date: Tue, 21 Aug 2007 11:45:47 -0400
Message-Id: <1187711147.5066.13.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Michael Kerrisk <mtk-manpages@gmx.net>
Cc: Andi Kleen <ak@suse.de>, linux-mm@kvack.org, akpm@linux-foundation.org, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

On Sat, 2007-08-18 at 07:50 +0200, Michael Kerrisk wrote:
> > Lee's changes are ok for me.
> > 
> > -Andi
> 
> Thanks Andi.
> 
> Lee, for each of th changed pages, could you write me a short summary
> of the changes, suitable for inclusion in the change log?

Michael:

The terse and generic description re:  adding missing semantics and
error returns to match kernel code is not sufficient?

What level of detail would be?

I have rebased the patch against the 2.64 man pages if you'd like me to
send that along.  There were a few conflicts, as you or someone had
moved some text around.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
