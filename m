Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by perninha.conectiva.com.br (Postfix) with SMTP id 1EBF338CBF
	for <linux-mm@kvack.org>; Wed, 21 Nov 2001 12:39:31 -0300 (EST)
Date: Wed, 21 Nov 2001 13:39:18 -0200 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: 2.4.14 + Bug in swap_out.
In-Reply-To: <Pine.LNX.4.21.0111211515210.1357-100000@localhost.localdomain>
Message-ID: <Pine.LNX.4.33L.0111211338330.1491-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, "David S. Miller" <davem@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 21 Nov 2001, Hugh Dickins wrote:

> > In that case, why can't we just take the next mm from
> > init_mm and just "roll over" our mm to the back of the
> > list once we're done with it ?
>
> No.  That's how it used to be, that's what I changed it from.
>
> fork and exec are well ordered in how they add to the mmlist,
> and that ordering (children after parent) suited swapoff nicely,
> to minimize duplication of a swapent while it's being unused;
> except swap_out randomized the order by cycling init_mm around it.

Urmmm, so the code was obfuscated in order to optimise
swapoff() ?

Exactly how bad was the "mmlist randomising" for swapoff() ?

regards,

Rik
-- 
DMCA, SSSCA, W3C?  Who cares?  http://thefreeworld.net/

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
