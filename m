Message-ID: <20010323122815.A6428@win.tue.nl>
Date: Fri, 23 Mar 2001 12:28:15 +0100
From: Guest section DW <dwguest@win.tue.nl>
Subject: Re: [PATCH] Prevent OOM from killing init
References: <20010323015358Z129164-406+3041@vger.kernel.org> <Pine.LNX.4.21.0103230403370.29682-100000@imladris.rielhome.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.4.21.0103230403370.29682-100000@imladris.rielhome.conectiva>; from Rik van Riel on Fri, Mar 23, 2001 at 04:04:09AM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>, Michael Peddemors <michael@linuxmagic.com>
Cc: Stephen Clouse <stephenc@theiqgroup.com>, Patrick O'Rourke <orourke@missioncriticallinux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 23, 2001 at 04:04:09AM -0300, Rik van Riel wrote:
> On 22 Mar 2001, Michael Peddemors wrote:
> 
> > Here, Here.. killing qmail on a server who's sole task is running mail
> > doesn't seem to make much sense either..
> 
> I won't defend the current OOM killing code.
> 
> Instead, I'm asking everybody who's unhappy with the
> current code to come up with something better.

To a murderer: "Why did you kill that old lady?"
Reply: "I won't defend that deed, but who else should I have killed?"

Andries - getting more and more unhappy with OOM

Mar 23 11:48:49 mette kernel: Out of Memory: Killed process 2019 (emacs).
Mar 23 11:48:49 mette kernel: Out of Memory: Killed process 1407 (emacs).
Mar 23 11:48:50 mette kernel: Out of Memory: Killed process 1495 (emacs).
Mar 23 11:48:50 mette kernel: Out of Memory: Killed process 2800 (rpm).

[yes, that was rpm growing too large, taking a few emacs sessions]
[2.4.2]
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
