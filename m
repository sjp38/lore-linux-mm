Date: Sun, 3 Sep 2000 17:47:01 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Rik van Riel's VM patch
In-Reply-To: <E13VYF1-0000gN-00@the-village.bc.nu>
Message-ID: <Pine.LNX.4.21.0009031743190.1112-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Bill Huey <billh@gnuppy.monkey.org>, John Levon <moz@compsoc.man.ac.uk>, linux-mm@kvack.org, "Theodore Y. Ts'o" <tytso@MIT.EDU>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, 3 Sep 2000, Alan Cox wrote:

> > Yes, it kicks butt and it finally (just about) removes the final
> > Linux kernel showstopper for recent kernels. ;-)
> 
> Things like random memory corruption from dropping dirty bits,
> and some of the others are far more serious showstoppers alas

Indeed, there are 4 major issues left in the VM area:

1) system hangs under load with 0 lowmem free (but still
   some high memory free)

   [not much details on this one yet]

2) dirty bits can get lost, try_to_swap_out() and other
   places have a race with the hardware

   [from mm/vmscan.c, line 60 has a race with the /hardware/]
     55         if (pte_young(pte)) {
     56                 /*
     57                  * Transfer the "accessed" bit from the page
     58                  * tables to the global page map.
     59                  */
     60                 set_pte(page_table, pte_mkold(pte));
     61                 SetPageReferenced(page);
     62                 goto out_failed;
     63         }

3) it appears something can corrupt page->count or delete a
   page from the cache while the page is locked

   [tripped up by my VM patch?]

4) the innd data corruption bug

   [anybody?]

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
