Date: Tue, 17 Aug 1999 02:17:11 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [bigmem-patch] 4GB with Linux on IA32
In-Reply-To: <Pine.LNX.4.10.9908162235570.4139-100000@laser.random>
Message-ID: <Pine.LNX.4.10.9908170212250.14570-100000@laser.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Kanoj Sarcar <kanoj@google.engr.sgi.com>, torvalds@transmeta.com, sct@redhat.com, Gerhard.Wichert@pdb.siemens.de, Winfried.Gerhard@pdb.siemens.de, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I uploaded a new bigmem-2.3.13-M patch here:

	ftp://e-mind.com/pub/andrea/kernel-patches/2.3.13/bigmem-2.3.13-M

(the raw-io must be avoided with bigmem enabled, since the protection I
added in get_page_map() doesn't work right now)

If you'll avoid to do raw-io the patch should be safe and ready to use.

Thanks.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
