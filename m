Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by perninha.conectiva.com.br (Postfix) with SMTP id 7FA8338CD6
	for <linux-mm@kvack.org>; Wed, 21 Nov 2001 11:20:33 -0300 (EST)
Date: Wed, 21 Nov 2001 12:20:23 -0200 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: 2.4.14 + Bug in swap_out.
In-Reply-To: <m1hero1c8o.fsf@frodo.biederman.org>
Message-ID: <Pine.LNX.4.33L.0111211219420.1491-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: "David S. Miller" <davem@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 21 Nov 2001, Eric W. Biederman wrote:

> We only hold a ref count for the duration of swap_out_mm.
> Not for the duration of the value in swap_mm.

In that case, why can't we just take the next mm from
init_mm and just "roll over" our mm to the back of the
list once we're done with it ?

Removing magic is good ;)

regards,

Rik
-- 
DMCA, SSSCA, W3C?  Who cares?  http://thefreeworld.net/

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
