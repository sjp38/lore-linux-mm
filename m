Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by postfix.conectiva.com.br (Postfix) with SMTP id CD7C016B19
	for <linux-mm@kvack.org>; Mon, 26 Mar 2001 17:15:36 -0300 (EST)
Date: Mon, 26 Mar 2001 17:05:21 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] Prevent OOM from killing init
In-Reply-To: <nn66gwnyhn.fsf@code.and.org>
Message-ID: <Pine.LNX.4.21.0103261704060.24763-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: James Antill <james@and.org>
Cc: Guest section DW <dwguest@win.tue.nl>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Stephen Clouse <stephenc@theiqgroup.com>, Patrick O'Rourke <orourke@missioncriticallinux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 26 Mar 2001, James Antill wrote:

>  If you want overcommit great, and I think it's a valid default
> ... but it'd be nice if I could say I don't want it for apps that
> aren't written using glib etc.

Agreed.  Jonathan Morton seems to be making progress in testing
and debugging the non-overcommit patch from some time ago. If
things turn out to be trivial enough I wouldn't be surprised if
we got to see the option of non-overcommit somewhere in future
2.4 and 2.5 kernels...

regards,

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
