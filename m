Received: from sap-ag.de ([194.39.131.3])
  by smtpde02.sap-ag.de (out) with ESMTP id TAA29354
  for <linux-mm@kvack.org>; Sun, 19 Nov 2000 19:08:27 +0100 (MEZ)
Received: from linux.local.wdf.sap-ag.de (ct4012.wdf.sap-ag.de [147.204.29.12])
	by sap-ag.de (8.8.8/8.8.8) with SMTP id TAA28508
	for <linux-mm@kvack.org>; Sun, 19 Nov 2000 19:13:20 +0100 (MET)
Resent-Message-Id: <200011191813.TAA28508@sap-ag.de>
Resent-To: linux-mm@kvack.org
Subject: Re: Hung kswapd (2.4.0-t11p5)
References: <3A146EDA.36D1F9C4@redhat.com>
From: Christoph Rohland <cr@sap.com>
In-Reply-To: Bob Matthews's message of "Thu, 16 Nov 2000 18:33:46 -0500"
Date: 19 Nov 2000 15:34:42 +0100
Message-ID: <m3n1ewyqrh.fsf@linux.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Bob Matthews <bmatthews@redhat.com>
Cc: riel@nl.linux.org, johnsonm@redhat.com
List-ID: <linux-mm.kvack.org>

Hi Bob and Rik,

Bob Matthews <bmatthews@redhat.com> writes:

> kswapd itself appears to be stuck here:
> 
> (gdb) list *0xc01394c2
> 0xc01394c2 is in create_buffers (buffer.c:1240).
> 1235	
> 1236		/* 
> 1237		 * Set our state for sleeping, then check again for buffer heads.
> 1238		 * This ensures we won't miss a wake_up from an interrupt.
> 1239		 */
> 1240		wait_event(buffer_wait, nr_unused_buffer_heads >=
> MAX_BUF_PER_PAGE);
> 1241		goto try_again;
> 1242	}
> 1243	
> 1244	static int create_page_buffers(int rw, struct page *page, kdev_t
> dev, int b[], int size)

That's apparently exactly the same place shm swapping gets
stuck. Apparently we run out of buffer heads on highmem machines (I
actually believe that we can trigger the same on lowmem machines also,
only under much higher load wrt the machine size, but that's only a
guess)

Greetings
                Christoph


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
