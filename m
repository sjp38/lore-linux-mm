Date: Wed, 31 May 2006 04:24:31 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [Patch 0/17] PTI: Explation of Clean Page Table Interface
In-Reply-To: <Pine.LNX.4.62.0605311111020.13018@weill.orchestra.cse.unsw.EDU.AU>
Message-ID: <Pine.LNX.4.64.0605310412530.5488@blonde.wat.veritas.com>
References: <Pine.LNX.4.61.0605301334520.10816@weill.orchestra.cse.unsw.EDU.AU>
 <yq0irnot028.fsf@jaguar.mkp.net> <Pine.LNX.4.61.0605301830300.22882@weill.orchestra.cse.unsw.EDU.AU>
 <447C055A.9070906@sgi.com> <Pine.LNX.4.62.0605311111020.13018@weill.orchestra.cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Cameron Davies <pauld@cse.unsw.EDU.AU>
Cc: Jes Sorensen <jes@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 31 May 2006, Paul Cameron Davies wrote:
> 
> What level of degradation in peformance in acceptable (if any)?

None.  What is the point in slowing it down, even on the architecture
you are targeting, while making it all more complicated, moving
significant code around from the .cs where we expect it into .hs?

And please, next time, make sure the patches can actually be applied:
your mailer (pine) messed with the whitespace - quell-flowed-text is,
I think, the feature you need to add, but mail yourself the patches
first as a test to make sure they can be applied by recipients.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
