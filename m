Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by postfix.conectiva.com.br (Postfix) with SMTP id 98DDE16B21
	for <linux-mm@kvack.org>; Thu, 22 Mar 2001 20:53:57 -0300 (EST)
Date: Thu, 22 Mar 2001 20:53:57 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] Prevent OOM from killing init
In-Reply-To: <3C9BCD6E.94A5BAA0@evision-ventures.com>
Message-ID: <Pine.LNX.4.33.0103222052100.24040-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Dalecki <dalecki@evision-ventures.com>
Cc: Stephen Clouse <stephenc@theiqgroup.com>, Guest section DW <dwguest@win.tue.nl>, Patrick O'Rourke <orourke@missioncriticallinux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, 23 Mar 2002, Martin Dalecki wrote:

> Uptime of a process is a much better mesaure for a killing
> candidate then it's size.

You'll have fun with your root shell, then  ;)

The current OOM code takes things like uptime, used cpu, size
and a bunch of other things into account.

If it turns out that the code is not attaching a proper weight
to some of these factors, you should be sending patches, not
flames.

(the code is full of comments, so it should be easy enough to
find your way around the code and tweak it until it does the
right thing in a number of test cases)

regards,

Rik
--
Linux MM bugzilla: http://linux-mm.org/bugzilla.shtml

Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
