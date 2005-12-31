Date: Sat, 31 Dec 2005 20:19:16 -0200
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: [PATCH 01/14] page-replace-single-batch-insert.patch
Message-ID: <20051231221916.GB4024@dmt.cnet>
References: <20051230223952.765.21096.sendpatchset@twins.localnet> <20051230224002.765.28812.sendpatchset@twins.localnet> <20051231070320.GA9997@dmt.cnet> <Pine.LNX.4.63.0512310943450.27198@cuia.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.63.0512310943450.27198@cuia.boston.redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@osdl.org>, Christoph Lameter <christoph@lameter.com>, Wu Fengguang <wfg@mail.ustc.edu.cn>, Nick Piggin <npiggin@suse.de>, Marijn Meijles <marijn@bitpit.net>
List-ID: <linux-mm.kvack.org>

On Sat, Dec 31, 2005 at 09:44:07AM -0500, Rik van Riel wrote:
> On Sat, 31 Dec 2005, Marcelo Tosatti wrote:
> 
> > Unification of active and inactive per cpu page lists is a requirement 
> > for CLOCK-Pro, right?
> 
> You can approximate the functionality through use of scan
> rates.  Not quite as accurate as a unified clock, though.

Rik, I dont understand what you mean.

My point is that the page-replacement-policy abstraction patches affect
the original behaviour, and they shouldnt. See the post from Peter about
abstracting the per-cpu lists.

We're talking about different things.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
