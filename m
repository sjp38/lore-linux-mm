Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by postfix.conectiva.com.br (Postfix) with SMTP id 5B6BF16FB1
	for <linux-mm@kvack.org>; Fri, 23 Mar 2001 04:07:09 -0300 (EST)
Date: Fri, 23 Mar 2001 04:04:09 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] Prevent OOM from killing init
In-Reply-To: <20010323015358Z129164-406+3041@vger.kernel.org>
Message-ID: <Pine.LNX.4.21.0103230403370.29682-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Michael Peddemors <michael@linuxmagic.com>
Cc: Stephen Clouse <stephenc@theiqgroup.com>, Guest section DW <dwguest@win.tue.nl>, Patrick O'Rourke <orourke@missioncriticallinux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 22 Mar 2001, Michael Peddemors wrote:

> Here, Here.. killing qmail on a server who's sole task is running mail
> doesn't seem to make much sense either..

I won't defend the current OOM killing code.

Instead, I'm asking everybody who's unhappy with the
current code to come up with something better.

Rik
--
Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com.br/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
