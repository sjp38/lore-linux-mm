Date: Tue, 12 Oct 2004 08:39:16 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: NUMA: Patch for node based swapping
In-Reply-To: <Pine.LNX.4.44.0410121126390.13693-100000@chimarrao.boston.redhat.com>
Message-ID: <Pine.LNX.4.58.0410120838570.12195@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.44.0410121126390.13693-100000@chimarrao.boston.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, nickpiggin@yahoo.com.au, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 12 Oct 2004, Rik van Riel wrote:
> On Tue, 12 Oct 2004, Christoph Lameter wrote:
> > The minimum may be controlled through /proc/sys/vm/node_swap.
> > By default node_swap is set to 100 which means that kswapd will be run on
> > a zone if less than 10% are available after allocation.
> That sounds like an extraordinarily bad idea for eg. AMD64
> systems, which have a very low numa factor.

Any other suggestions?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
