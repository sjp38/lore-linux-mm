Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA19611
	for <linux-mm@kvack.org>; Sun, 24 Jan 1999 13:41:34 -0500
Date: Sun, 24 Jan 1999 19:40:22 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: [patch] arca-vm-29, nr_freeable_pages working now
Message-ID: <Pine.LNX.3.96.990124192824.208A-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: linux@billabong.demon.co.uk, zimerman@deskmail.com, mauelsha@ez-darmstadt.telekom.de, gerritse@wnet.bos.nl, dlux@dlux.sch.bme.hu, jalvo@cloud9.net, ebiederm+eric@ccr.net, steve@netplus.net, "Stephen C. Tweedie" <sct@redhat.com>, Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I have a new VM patch. Unfortunately it's impossible for me to extract it
clean from my tree without waste tons of time. So to try it you'll have to
apply my new whole 2.2.0-pre9_arca-1 patch (that include also some other
new stuff).

ftp://e-mind.com/pub/linux/arca-tree/2.2.0-pre9_arca-1.gz

I am interested about benchmark results and comments if you'll try it. I
am interested also about the low memory feeling. It seems rock solid here
and I had a > x2 improvement against previous code (with 128Mbyte of RAM). 
Iteractive feel seems still quite good. 

With this patch you'll have a /proc/sys/vm/pager with one number into it. 
Such value is the percentage of freeable pages you want during heavy swap. 
The most this percentage is high the most your system will run smoother,
but the applications that needs memory will run slower. As default it's
set to 5%. 

Andrea Arcangeli

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
