Message-ID: <20010323002752.A5650@win.tue.nl>
Date: Fri, 23 Mar 2001 00:27:52 +0100
From: Guest section DW <dwguest@win.tue.nl>
Subject: Re: [PATCH] Prevent OOM from killing init
References: <20010322230041.A5598@win.tue.nl> <E14gDwB-0003Tj-00@the-village.bc.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <E14gDwB-0003Tj-00@the-village.bc.nu>; from Alan Cox on Thu, Mar 22, 2001 at 10:52:09PM +0000
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Stephen Clouse <stephenc@theiqgroup.com>, Rik van Riel <riel@conectiva.com.br>, Patrick O'Rourke <orourke@missioncriticallinux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 22, 2001 at 10:52:09PM +0000, Alan Cox wrote:

> > You see, the bug is that malloc does not fail. This means that the
> > decisions about what to do are not taken by the program that knows
> > what it is doing, but by the kernel.

> Even if malloc fails the situation is no different.

Why do you say so?

> You can do overcommit avoidance in Linux if you are bored enough to try it.

Would you accept it as the default? Would Linus?

(With disk I/O we are terribly conservative, using very cautious settings,
and many people use hdparm to double or triple their disk speed.
But for a few these optimistic settings cause data corruption,
so we do not make it the default.
Similarly I would be happy if the "no overcommit", "no OOM killer"
situation was the default. The people who need a reliable system
will leave it that way. The people who do not mind if some process
is killed once in a while use vmparm or /proc/vm/overcommit or so
to make Linux achieve more on average.)

Andries
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
