Date: Thu, 31 Aug 2000 18:15:01 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: [PATCH *] VM patch w/ drop behind for 2.4.0-test8-pre1
Message-ID: <Pine.LNX.4.21.0008311801570.7217-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.redhat.com
List-ID: <linux-mm.kvack.org>

Hi,

today I released a new version of my VM patch for 2.4.0-test.

This patch should mostly fix streaming IO performance, due
to the following two features:
- drop_behind(), when we do a readahead, move the pages
  'behind' us to the inactive list .. this way we can do
  streaming IO without putting pressure on the working set
- deactivate pages in generic_file_write(), this does
  basically the same ... by moving the pages we write to 
  to the inactive_dirty list, a big download, etc.. doesn't
  impact the working set of the system

I'm particularly interested in the impact of streaming IO on
the performance of the rest of the system with this patch, but
of course also in the performance of the streaming IO itself.

The patch is available from:

	http://www.surriel.com/patches/

	http://www.surriel.com/patches/2.4.0-t8p1-vmpatch2

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
