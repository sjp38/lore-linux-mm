Date: Wed, 7 Dec 2005 10:24:58 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [RFC 1/3] Framework for accurate node based statistics 
In-Reply-To: <9353.1133934652@kao2.melbourne.sgi.com>
Message-ID: <Pine.LNX.4.62.0512071023530.24516@schroedinger.engr.sgi.com>
References: <9353.1133934652@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Keith Owens <kaos@sgi.com>
Cc: Andi Kleen <ak@suse.de>, linux-kernel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, linux-ia64@vger.kernel.org, Marcelo Tosatti <marcelo.tosatti@cyclades.com>
List-ID: <linux-mm.kvack.org>

On Wed, 7 Dec 2005, Keith Owens wrote:

> On Tue, 6 Dec 2005 14:52:33 -0800 (PST), 
> Christoph Lameter <clameter@engr.sgi.com> wrote:
> >+DEFINE_PER_CPU(local_t [MAX_NUMNODES][NR_STAT_ITEMS], vm_stat_diff);
> 
> How big is that array going to get?  The total per cpu data area is
> limited to 64K on IA64 and we already use at least 34K.

Maximum around 1k nodes and I guess we may end up with 16 counters:

1024*16*8 = 131k ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
