From: Andi Kleen <ak@suse.de>
Subject: Re: zoned vm counters: per zone counter functionality
Date: Wed, 14 Jun 2006 07:53:51 +0200
References: <20060612211244.20862.41106.sendpatchset@schroedinger.engr.sgi.com> <448F64A0.9090705@yahoo.com.au> <Pine.LNX.4.64.0606140636130.780@blonde.wat.veritas.com>
In-Reply-To: <Pine.LNX.4.64.0606140636130.780@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200606140753.51092.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Christoph Lameter <clameter@sgi.com>, linux-kernel@vger.kernel.org, akpm@osdl.org, Con Kolivas <kernel@kolivas.org>, Marcelo Tosatti <marcelo@kvack.org>, linux-mm@kvack.org, Dave Chinner <dgc@sgi.com>
List-ID: <linux-mm.kvack.org>

On Wednesday 14 June 2006 07:37, Hugh Dickins wrote:
> On Wed, 14 Jun 2006, Nick Piggin wrote:
> > 
> > Hmm, then NR_ANON would become VM_ZONE_STAT_NR_ANON? That might be a bit
> > long for your tastes, maybe the prefix could be hidden by "clever" macros?
> 
> Don't even begin to think of "clever" macros.

Yes they cause cancer of the grep. SCNR.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
