Date: Fri, 22 Sep 2000 05:39:43 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [patch *] VM deadlock fix
In-Reply-To: <200009212223.PAA04238@pizda.ninka.net>
Message-ID: <Pine.LNX.4.21.0009220538500.27435-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: torvalds@transmeta.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 21 Sep 2000, David S. Miller wrote:

> How did you get away with adding a new member to task_struct yet
> not updating the INIT_TASK() macro appropriately? :-)  Does it
> really compile?

There are a lot of fields in the task_struct which
do not have fields declared in the INIT_TASK macro.

They seem to be set to zero by default.

regards,

Rik
--
"What you're running that piece of shit Gnome?!?!"
       -- Miguel de Icaza, UKUUG 2000

http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
