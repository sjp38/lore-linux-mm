Date: Mon, 10 Apr 2000 23:21:49 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: zap_page_range(): TLB flush race
Message-ID: <20000410232149.M17648@redhat.com>
References: <200004082331.QAA78522@google.engr.sgi.com> <E12e4mo-0003Pn-00@the-village.bc.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <E12e4mo-0003Pn-00@the-village.bc.nu>; from alan@lxorguk.ukuu.org.uk on Sun, Apr 09, 2000 at 12:37:05AM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Kanoj Sarcar <kanoj@google.engr.sgi.com>, Manfred Spraul <manfreds@colorfullife.com>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, torvalds@transmeta.com, davem@redhat.com
List-ID: <linux-mm.kvack.org>

Hi,

On Sun, Apr 09, 2000 at 12:37:05AM +0100, Alan Cox wrote:
> 
> Basically establish_pte() has to be architecture specific, as some processors
> need different orders either to avoid races or to handle cpu specific
> limitations.

What exactly do different architectures need which set_pte() doesn't 
already allow them to do magic in?  

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
