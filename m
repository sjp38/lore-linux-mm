Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by perninha.conectiva.com.br (Postfix) with SMTP id 2EAF338CE1
	for <linux-mm@kvack.org>; Mon, 23 Jul 2001 14:26:14 -0300 (EST)
Date: Mon, 23 Jul 2001 14:26:13 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Swap progress accounting
In-Reply-To: <20010723061512.A21588@devserv.devel.redhat.com>
Message-ID: <Pine.LNX.4.33L.0107231425190.20326-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Arjan van de Ven <arjanv@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 23 Jul 2001, Arjan van de Ven wrote:

> Currently, calling swap_out() on a zone doesn't count progress, and the
> result can be that you swap_out() a lot of pages, and still return "no
> progress possible" to try_to_free_pages(), which in turn makes a GFP_KERNEL
> allocation fail (and that can kill init).

"makes GFP_KERNEL allocation fail" ?!?!?!

Who the fuck broke __alloc_pages() while I wasn't looking ?

Why don't you fix __alloc_pages() instead ?


Rik
--
Executive summary of a recent Microsoft press release:
   "we are concerned about the GNU General Public License (GPL)"


		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
