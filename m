Date: Thu, 15 Aug 2002 19:14:49 -0700
Subject: Re: [PATCH] don't write all inactive pages at once
Message-ID: <20020816021449.GA1531@gnuppy.monkey.org>
References: <Pine.LNX.4.44L.0208152122130.23404-100000@imladris.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44L.0208152122130.23404-100000@imladris.surriel.com>
From: Bill Huey (Hui) <billh@gnuppy.monkey.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Bill Huey (Hui)" <billh@gnuppy.monkey.org>
List-ID: <linux-mm.kvack.org>

On Thu, Aug 15, 2002 at 09:24:45PM -0300, Rik van Riel wrote:
> Hi,
> 
> the following patch, against current 2.4-rmap, makes sure we don't
> write the whole inactive dirty list to disk at once and seems to
> greatly improve system response time when under swap or other heavy
> IO load.
> 
> Scanning could be much more efficient by using a marker page or
> similar tricks, but for now I'm going for the minimalist approach.
> If this thing works I'll make it fancy.
> 
> Please test this patch and let me know what you think.

Hey,

Test your patch ? What ??!?!! :)

Actually, the interactivity is much better overall and it seems to
much less stupid stuff (by non-empirical feel) than it use to.

It's just a matter of seeing if my experiences are backed up by
others using this patch. ;)

(/me hopes)

bill

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
