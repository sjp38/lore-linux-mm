Date: Thu, 21 Sep 2000 13:44:35 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: [patch *] VM deadlock fix
Message-ID: <Pine.LNX.4.21.0009211340110.18809-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-kernel@vger.redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

I've found and fixed the deadlocks in the new VM. They turned out 
to be single-cpu only bugs, which explains why they didn't crash my
SMP tesnt box ;)

They have to do with the fact that processes schedule away while
holding IO locks after waking up kswapd. At that point kswapd
spends its time spinning on the IO locks and single-cpu systems
will die...

Due to bad connectivity I'm not attaching this patch but have only
put it online on my home page:

http://www.surriel.com/patches/2.4.0-t9p2-vmpatch

(yes, I'm at a conference now ... the worst beating this patch
has had is a full night in 'make bzImage' with mem=8m)

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
