Date: Fri, 24 Aug 2001 12:16:12 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: SWAP_MAP_MAX: How?
Message-ID: <Pine.LNX.4.21.0108241158230.979-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>, Ben LaHaise <bcrl@redhat.com>, Marcelo Tosatti <marcelo@conectiva.com.br>, Rik van Riel <riel@conectiva.com.br>, Stephen Tweedie <sct@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The SWAP_MAP_MAX case imposes a severe constraint on how swapoff
may be implemented correctly.  I am still struggling to understand
how a swap count might reach SWAP_MAP_MAX 0x7fff on 2.4.  Please,
can someone enlighten me?

Thanks,
Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
