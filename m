From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] NUMA policies in the slab allocator V2
Date: Fri, 18 Nov 2005 05:31:47 +0100
References: <Pine.LNX.4.62.0511171745410.22486@schroedinger.engr.sgi.com> <200511180359.17598.ak@suse.de> <Pine.LNX.4.62.0511171925090.22785@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0511171925090.22785@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200511180531.47764.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On Friday 18 November 2005 04:38, Christoph Lameter wrote:
> You really want to run the useless fastpath? Examine lists etc for
> the local node despite the policy telling you to get off node?

Yes.

> Hmm. Is a hugepage ever allocated from interrupt context?

They aren't.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
