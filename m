Message-ID: <396B0CE3.8A745CA6@norran.net>
Date: Tue, 11 Jul 2000 14:02:43 +0200
From: Roger Larsson <roger.larsson@norran.net>
MIME-Version: 1.0
Subject: Warning: [PATCH] embryotic page ageing with lists
References: <396A6A11.1906927A@norran.net>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-kernel@vger.rutgers.edu" <linux-kernel@vger.rutgers.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

More testing has revieled that something strange happens...
(as always) as patched on test3-pre6 will try to patch on
a newer (or older more stable) kernel tonight.

X craches when I fire up Netscape and hovers the mouse over
the "shortcut" area... (Bus error)

I have got segmentation faults with
 time stress_diskread
And it is time that cores...!!!

It is like the page is indicated as read - but then it is
gone...

/RogerL

Roger Larsson wrote:
> 
> Hi,
> 
> (Sent this to linux-mm only and waited... I have not got it back yet
>  more than 2 h later - resending it to linux-kernel too)
> 
> This is a embryotic, but with heart beats, patch of page ageing
> for test3-pre6.
> 
> Features:
> * does NOT add any field in page structure.
> * round robin lists is used to simulate ageing.
> * referenced pages are moved 5 steps forward.
> * non freeable, tryagain, are moved 3 steps forward.
> * new pages are inserted 2 steps forward.
> * no pages are moved backward or to currently scanned.
> 
> Future work:
> * trim offsets / size / priority
> * remove code that unnecessary sets page as referenced (riel?)
> * add more offsets depending on why the page could not
>   be freed.
> * split pagemap_lru_lock (if wanted on SMP)
> * move pages of zones with pressure less forward...
> * ...
> 
> /RogerL
> 
> --
> Home page:
>   http://www.norran.net/nra02596/
> 
>   ------------------------------------------------------------------------
>                                        Name: patch-2.4.0-test3-pre6-filemap.1
>    patch-2.4.0-test3-pre6-filemap.1    Type: Plain Text (text/plain)
>                                    Encoding: 7bit

--
Home page:
  http://www.norran.net/nra02596/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
