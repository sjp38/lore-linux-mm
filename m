Date: Wed, 26 Apr 2000 17:09:37 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: [PATCH] 2.3.99-pre6-3+  VM rebalancing
Message-ID: <20000426170937.R3792@redhat.com>
References: <Pine.LNX.4.21.0004251418520.10408-100000@duckman.conectiva> <20000425113616.A7176@stormix.com> <3905EB26.8DBFD111@mandrakesoft.com> <20000425120657.B7176@stormix.com> <20000426120130.E3792@redhat.com> <200004261125.EAA12302@pizda.ninka.net> <20000426140031.L3792@redhat.com> <200004261311.GAA13838@pizda.ninka.net> <20000426162353.O3792@redhat.com> <200004261525.IAA13973@pizda.ninka.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <200004261525.IAA13973@pizda.ninka.net>; from davem@redhat.com on Wed, Apr 26, 2000 at 08:25:59AM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: sct@redhat.com, sim@stormix.com, jgarzik@mandrakesoft.com, riel@nl.linux.org, andrea@suse.de, linux-mm@kvack.org, bcrl@redhat.com, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Apr 26, 2000 at 08:25:59AM -0700, David S. Miller wrote:
> 
> No, this is why I haven't posted the complete patch for general
> consumption.  It's in an "almost works" state, very dangerous,
> and I don't even try leaving single user mode when I'm testing
> it :-)))

OK.  You might find this useful:

	ftp://ftp.uk.linux.org/pub/linux/sct/vm/mtest.c

which is a small utility I wrote while I was testing the 
swap cache code.  It creates a heap of memory, forks a variable
number of reader and/or writer processes to access that heap,
and touches/modifies the heap randomly from the children.  It 
is very good at testing the swap code for pages shared over 
fork.  It's what I use any time I need to push a box into swap
for VM testing.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
