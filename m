Date: Mon, 25 Feb 2002 18:46:12 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH] struct page shrinkage
Message-ID: <20020226024612.GO3511@holomorphy.com>
References: <Pine.LNX.4.33L.0202252245460.7820-100000@imladris.surriel.com> <3C7AF011.8B6ECCF0@zip.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <3C7AF011.8B6ECCF0@zip.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: Rik van Riel <riel@conectiva.com.br>, "Marcelo W. Tosatti" <marcelo@conectiva.com.br>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
>> 
>> +               clear_bit(PG_locked, &p->flags);

On Mon, Feb 25, 2002 at 06:16:49PM -0800, Andrew Morton wrote:
> Please don't do this.  Please use the macros.  If they're not
> there, please create them.
> 
> Bypassing the abstractions in this manner confounds people
> who are implementing global locked-page accounting.
> 
> In fact, I think I'll go rename all the page flags...

This is lingering context from the driver... it's ugly, I didn't
go after cleaning that up when I had to touch this function because
of the usual minimal-impact / only do one thing principle.

Perhaps others were similarly (un)motivated.


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
