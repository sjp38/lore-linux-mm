Subject: Re: [PATCH/RFC 0/5] Memory Policy Cleanups and Enhancements
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20070916180527.GB15184@skynet.ie>
References: <20070830185053.22619.96398.sendpatchset@localhost>
	 <1189527657.5036.35.camel@localhost>
	 <Pine.LNX.4.64.0709121515210.3835@schroedinger.engr.sgi.com>
	 <1189691837.5013.43.camel@localhost>
	 <Pine.LNX.4.64.0709131118190.9378@schroedinger.engr.sgi.com>
	 <20070913182344.GB23752@skynet.ie>
	 <Pine.LNX.4.64.0709131124100.9378@schroedinger.engr.sgi.com>
	 <20070913141704.4623ac57.akpm@linux-foundation.org>
	 <20070914085335.GA30407@skynet.ie> <1189800926.5315.76.camel@localhost>
	 <20070916180527.GB15184@skynet.ie>
Content-Type: text/plain
Date: Mon, 17 Sep 2007 09:29:50 -0400
Message-Id: <1190035790.5460.2.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, ak@suse.de, mtk-manpages@gmx.net, solo@google.com, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Sun, 2007-09-16 at 19:05 +0100, Mel Gorman wrote:
> On (14/09/07 16:15), Lee Schermerhorn didst pronounce:


> > 
> > I've also run a moderate stress test [half an hour now] and it's holding
> > up.  
> > 
> 
> Great.

FYI:  I let the exerciser tests run over the weekend.  As of this
morning they had run for ~65.5 hours with no console messages.  One of
the "bin" tests [hexdump] had exited with non-zero status at some point,
but insufficient info to diagonose.

Still, pretty solid.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
