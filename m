Date: Sun, 23 Sep 2001 12:53:56 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: [PATCH *] page aging fixed, 2.4.9-ac14
Message-ID: <Pine.LNX.4.33L.0109231251070.19147-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Alan,

I've made a new page aging patch, this time against 2.4.9-ac14;
this one has two added features over the patch against 2.4.9-ac12:

1) uses min()/max() for smaller page_age_{up,down} functions

2) if we have no free shortage, don't waste CPU time trying
   to enforce the inactive target but rely on background
   scanning only

You can get the patch (a bit large for email) at:

   http://www.surriel.com/patches/2.4/2.4.9-ac14-aging

Please apply for the next 2.4.9-ac kernel, thanks.

regards,


Rik
-- 
IA64: a worthy successor to i860.

http://www.surriel.com/		http://distro.conectiva.com/

Send all your spam to aardvark@nl.linux.org (spam digging piggy)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
