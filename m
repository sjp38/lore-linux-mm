Subject: Re: zap_page_range(): TLB flush race
Date: Tue, 11 Apr 2000 12:56:59 +0100 (BST)
In-Reply-To: <20000410232149.M17648@redhat.com> from "Stephen C. Tweedie" at Apr 10, 2000 11:21:49 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <E12ezHx-0007RL-00@the-village.bc.nu>
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Kanoj Sarcar <kanoj@google.engr.sgi.com>, Manfred Spraul <manfreds@colorfullife.com>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, torvalds@transmeta.com, davem@redhat.com
List-ID: <linux-mm.kvack.org>

> What exactly do different architectures need which set_pte() doesn't 
> already allow them to do magic in?  

Some of them need a valid PTE to exist in order to flush a page from cache
to memory


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
