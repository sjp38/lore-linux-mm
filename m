Subject: Re: [RFC] memory defragmentation to satisfy high order allocations
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20041001190430.GA4372@logos.cnet>
References: <20041001182221.GA3191@logos.cnet>
	 <20041001131147.3780722b.akpm@osdl.org>  <20041001190430.GA4372@logos.cnet>
Content-Type: text/plain
Message-Id: <1096667823.3684.1299.camel@localhost>
Mime-Version: 1.0
Date: Fri, 01 Oct 2004 14:57:03 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm <linux-mm@kvack.org>, piggin@cyberone.com.au, Arjan van de Ven <arjanv@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2004-10-01 at 12:04, Marcelo Tosatti wrote:
> On Fri, Oct 01, 2004 at 01:11:47PM -0700, Andrew Morton wrote:
> > Presumably this duplicates some of the memory hot-remove patches.
> 
> As far as I have researched, the memory moving/remapping code 
> on the hot remove patches dont work correctly. Please correct me.

I definitely see some commonality, but Marcelo's approach has handling
for the different kinds of pages broken out much more nicely.  Can't
tell yet if this produces extra code, or is just plain better.  

We worked pretty hard to try and copy as little code as possible.  Was
there any reason that there was so much stuff copied out of rmap.c? 
Just for proof-of-concept?

Here's one of the recent patch sets that we're working on:

http://sprucegoose.sr71.net/patches/2.6.9-rc2-mm4-mhp-test2/

In that directory, the K* patches hijack some of the swap code (but
require memory pressure to work last time I tried), and the p000*
patches (by Hirokazu Takahashi) actively migrate pages around.  Both
approaches work, but the K* one is smaller and less intrusive, while the
p000* one is much more complete.  They may end up being able to coexist
in the end.  

> And what I've seen (from the Fujitsu guys) was quite ugly IMHO.

I don't work for Fujitsu :)  Please take a look at the patches in the
above directory and see what you think.  I'm sure you have some very
good stuff in your patch, but I need to take a closer look.

I'm just about to head out of town for the weekend, but I'll take a much
more detailed look on Monday.  

-- 
Dave Hansen
haveblue@us.ibm.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
