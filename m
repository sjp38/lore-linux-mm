From: Con Kolivas <kernel@kolivas.org>
Subject: Re: [PATCH 19/21] swap_prefetch: Conversion of nr_unstable to ZVC
Date: Tue, 13 Jun 2006 10:19:07 +1000
References: <20060612211244.20862.41106.sendpatchset@schroedinger.engr.sgi.com> <200606130959.48006.kernel@kolivas.org> <Pine.LNX.4.64.0606121707130.22052@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0606121707130.22052@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200606131019.08228.kernel@kolivas.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-kernel@vger.kernel.org, akpm@osdl.org, Hugh Dickins <hugh@veritas.com>, Marcelo Tosatti <marcelo@kvack.org>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, Andi Kleen <ak@suse.de>, Dave Chinner <dgc@sgi.com>
List-ID: <linux-mm.kvack.org>

On Tuesday 13 June 2006 10:08, Christoph Lameter wrote:
> On Tue, 13 Jun 2006, Con Kolivas wrote:
> > The comment should read something like:
>
> If we need another round then maybe it would be best if you would do that
> patch.

Sorry about that I wasn't trying to pester you.

> This?

Looks good :)

> Subject: swap_prefetch: conversion of nr_unstable to per zone counter
> From: Christoph Lameter <clameter@sgi.com>
>
> The determination of the vm state is now not that expensive
> anymore after we remove the use of the page state.
> Change the logic to avoid the expensive checks.
>
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> Signed-off-by: Con Kolivas <kernel@kolivas.org>

Thanks for your work on this.

-- 
-ck

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
