Message-ID: <393ECC87.E4CAA5D6@reiser.to>
Date: Wed, 07 Jun 2000 15:28:23 -0700
From: Hans Reiser <hans@reiser.to>
MIME-Version: 1.0
Subject: Re: journaling & VM  (was: Re: reiserfs being part of the kernel:
 it'snot just the code)
References: <393E8AEF.7A782FE4@reiser.to> <Pine.LNX.4.21.0006071459040.14304-100000@duckman.distro.conectiva> <20000607205819.E30951@redhat.com> <ytt1z29dxce.fsf@serpe.mitica> <20000607222421.H30951@redhat.com> <yttvgzlcgps.fsf@serpe.mitica> <20000607224908.K30951@redhat.com>
Content-Type: text/plain; charset=koi8-r
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: "Juan J. Quintela" <quintela@fi.udc.es>, Rik van Riel <riel@conectiva.com.br>, bert hubert <ahu@ds9a.nl>, linux-kernel@vger.rutgers.edu, Chris Mason <mason@suse.com>, linux-mm@kvack.org, Alexander Zarochentcev <zam@odintsovo.comcor.ru>
List-ID: <linux-mm.kvack.org>

Juan, while the FS cannot immediately unpin the pages, if pushed into doing so
it can startup the mechanisms to unpin them.  The pressure to start those
mechanisms should be proportional to the amount of pages it is hogging.

Memory pressure should have a central pusher and decentralized FS delegated
response to the pushing.

Hans
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
