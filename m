From: Christoph Rohland <cr@sap.com>
Subject: New mm and highmem reminder
Date: 25 Oct 2000 19:04:18 +0200
Message-ID: <qwwy9zcam3x.fsf@sap.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>, Ingo Molnar <mingo@elte.hu>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Rik and Ingo,

Just wanted to remind you that swapping shm in highmem is still broken
in the latest patches. 

If I return a RETRY in shm_swap_core instead of FAILED for failures of
prepare_highmem_swapout it survives a little bit longer spewing lots
of 'order 0 allocation failed' and then locks up after doing some
swapping. Without this change it hardly swaps at all before lockup.

It may not be introduced by Riks vm but swapping in shm with PAE
worked quite nice until these changes.

Greetings
		Christoph

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
