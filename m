Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA14306
	for <linux-mm@kvack.org>; Thu, 21 Jan 1999 15:43:09 -0500
Date: Thu, 21 Jan 1999 21:17:49 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: [patch] arca-vm-28 - new nr_freeable_pages
In-Reply-To: <Pine.LNX.3.96.990120162138.4544A-100000@laser.bogus>
Message-ID: <Pine.LNX.3.96.990121210148.2760B-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
Cc: Nimrod Zimerman <zimerman@deskmail.com>, John Alvord <jalvo@cloud9.net>, "Stephen C. Tweedie" <sct@redhat.com>, Steve Bergman <steve@netplus.net>, dlux@dlux.sch.bme.hu, "Nicholas J. Leon" <nicholas@binary9.net>, Kalle Andersson <kalle@sslug.dk>, Heinz Mauelshagen <mauelsha@ez-darmstadt.telekom.de>, Ben McCann <bmccann@indusriver.com>"Stephen C. Tweedie" <sct@redhat.com>, Rik van Riel <H.H.vanRiel@phys.uu.nl>
List-ID: <linux-mm.kvack.org>

I have a new arca-vm-28. I don't have time to comment the changes right
now, but I would like if you could try it and feedback. This is not
intended to be good in low memory system, it _could_ work fine also with
low mem, but I don't know...

I can tell you that the bench that was running in 100 sec in pre1 and in
50 sec since I killed kswapd, now it runs in 20 sec. Iteractive
performances seems good. Let me know.

Forget to tell, if it will be crazy or it will not compile, I could have
done mistakes in diffing the stuff (it's becoming a relevant work ;), in
such case you can download arca-109 that has arca-vm-28 included as well. 

ftp://e-mind.com/pub/linux/kernel-patches/2.2.0-pre8testing-arca-VM-28.gz

Andrea Arcangeli

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
