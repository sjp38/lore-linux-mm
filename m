From: Alan Cox <alan@redhat.com>
Message-Id: <200006201703.NAA09985@devserv.devel.redhat.com>
Subject: Re: shrink_mmap() change in ac-21
Date: Tue, 20 Jun 2000 13:03:32 -0400 (EDT)
In-Reply-To: <20000620130130.I28546@vodka.thepuffingroup.com> from "willy@thepuffingroup.com" at Jun 20, 2000 01:01:30 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: willy@thepuffingroup.com
Cc: Manfred Spraul <manfred@colorfullife.com>, zlatko@iskon.hr, alan@redhat.com, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

> Not that I want to get involved with the VM system in _any way at all_,
> but bcrl pointed out that highmem doesn't really cost a lot, so why not
> change to:

A lot of stuff has to be in the low block. It would hurt 8Gig users badly
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
