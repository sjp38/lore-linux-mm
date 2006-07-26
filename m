Date: Wed, 26 Jul 2006 07:03:59 -0300
From: Marcelo Tosatti <mtosatti@redhat.com>
Subject: Re: [PATCH 0/39] mm: 2.6.17-pr1 - generic page-replacement framework and 4 new policies
Message-ID: <20060726100359.GA20096@dmt>
References: <20060712143659.16998.6444.sendpatchset@lappy> <Pine.LNX.4.64.0607130838360.27189@schroedinger.engr.sgi.com> <1152982981.31891.46.camel@lappy> <Pine.LNX.4.64.0607152049290.11274@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0607152049290.11274@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Jul 15, 2006 at 08:50:06PM -0700, Christoph Lameter wrote:
> On Sat, 15 Jul 2006, Peter Zijlstra wrote:
> 
> > Now on the why, I still believe one of the advanced page replacement
> > algorithms are better than the currently implemented. If only because
> > they have access to more information, namely that provided by the
> > nonresident page tracking. (Which, as shown by Rik's OLS entry this
> > year, provides more interresting uses)
> 
> Could you show us some workloads where this makes a significant 
> difference?

http://www.linux-mm.org/PageReplacementTesting for instance.

Check the CLOCKPro/ARC papers for more details.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
