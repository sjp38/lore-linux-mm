Date: Thu, 12 Oct 2000 17:29:39 -0700
Message-Id: <200010130029.RAA18914@pizda.ninka.net>
From: "David S. Miller" <davem@redhat.com>
In-reply-to: <Pine.LNX.4.21.0010130114090.13322-100000@neo.local>
	(davej@suse.de)
Subject: Re: Updated Linux 2.4 Status/TODO List (from the ALS show)
References: <Pine.LNX.4.21.0010130114090.13322-100000@neo.local>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: davej@suse.de
Cc: tytso@mit.edu, torvalds@transmeta.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

   Any of the mm gurus give the patch below a quick once over ?  Is
   this adequate, or is there more to this than the description
   implies?

It might make more sense to just make rss an atomic_t.

Later,
David S. Miller
davem@redhat.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
