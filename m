Subject: Re: [PATCH/RFC 4/5] Mem Policy:  cpuset-independent interleave
	policy
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0710091148220.32730@schroedinger.engr.sgi.com>
References: <20070830185053.22619.96398.sendpatchset@localhost>
	 <20070830185122.22619.56636.sendpatchset@localhost>
	 <46E86148.9060400@google.com> <1189690357.5013.19.camel@localhost>
	 <470B1C77.1080001@google.com>
	 <Pine.LNX.4.64.0710091148220.32730@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Tue, 09 Oct 2007 15:02:29 -0400
Message-Id: <1191956550.5252.21.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Ethan Solomita <solo@google.com>, linux-mm@kvack.org, akpm@linux-foundation.org, ak@suse.de, mtk-manpages@gmx.net, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Tue, 2007-10-09 at 11:49 -0700, Christoph Lameter wrote:
> On Mon, 8 Oct 2007, Ethan Solomita wrote:
> 
> > 	Do we want do_get_mempolicy() to return a policy number with
> > MPOL_CONTEXT set? That's what's happening with this patch, and I expect it'll
> > confuse userland apps, e.g. numactl.
> 
> Do we have a consistent way to deal with MPOL_CONTEXT now? I thought this 
> was just to test some ideas.


Not sure your meaning, here, Christoph.  Ethan did find a bug in my
patch.  That WAS an RFC, I believe.  I plan on reissuing that patch
along with the other cleanups after Mel's stuff goes in, as I'm
currently testing my patches atop his.  I have a couple of other
independent, and more urgent fixes that I'll post as soon as I finish
testing.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
