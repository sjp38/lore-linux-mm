Date: Sun, 6 Apr 2003 22:55:30 +0100
From: Jamie Lokier <jamie@shareable.org>
Subject: Re: subobj-rmap
Message-ID: <20030406215530.GC24710@mail.jlokier.co.uk>
References: <1070000.1049664851@[10.10.2.4]> <Pine.LNX.4.44.0304061737510.2296-100000@chimarrao.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0304061737510.2296-100000@chimarrao.boston.redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@surriel.com>
Cc: "Martin J. Bligh" <mbligh@aracnet.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Andrew Morton <akpm@digeo.com>, andrea@suse.de, mingo@elte.hu, hugh@veritas.com, dmccr@us.ibm.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Bill Irwin <wli@holomorphy.com>
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> I don't see how the data structure you describe
> would allow us to efficiently select the subset
> of VMAs for which:
> 
> 1) the start address is smaller than the address we want
> and
> 2) the end address is larger than the address we want

Think about the data structures some text editors use to describe
special regions of the text.  A common operation is to search for all
the special regions covering a particular cursor position.

Several data structures are available.  I'm not aware of any that have
perfect behaviour in all corner cases.

It might be worth noting that these data structures are good at
determining the set of regions covering position X+1 having recently
calculated the set for position X.  Perhaps that has relevance for
speeding up page scanning?

-- Jamie
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
