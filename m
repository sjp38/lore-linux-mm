Date: Tue, 11 Apr 2000 10:14:18 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: zap_page_range(): TLB flush race
Message-ID: <20000411101418.E2740@redhat.com>
References: <200004082331.QAA78522@google.engr.sgi.com> <E12e4mo-0003Pn-00@the-village.bc.nu> <20000410232149.M17648@redhat.com> <200004102312.QAA05115@pizda.ninka.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <200004102312.QAA05115@pizda.ninka.net>; from davem@redhat.com on Mon, Apr 10, 2000 at 04:12:18PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: sct@redhat.com, alan@lxorguk.ukuu.org.uk, kanoj@google.engr.sgi.com, manfreds@colorfullife.com, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, torvalds@transmeta.com
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, Apr 10, 2000 at 04:12:18PM -0700, David S. Miller wrote:
>    On Sun, Apr 09, 2000 at 12:37:05AM +0100, Alan Cox wrote:
>    > 
>    > Basically establish_pte() has to be architecture specific, as some processors
>    > need different orders either to avoid races or to handle cpu specific
>    > limitations.
> 
>    What exactly do different architectures need which set_pte() doesn't 
>    already allow them to do magic in?  
> 
> Doing a properly synchronized PTE update and Cache/TLB flush when the
> mapping can exist on multiple processors is not most efficiently done
> if we take some generic setup.

OK, I'm sure there are optimisation issues, but I was worried about
correctness problems from what Alan said.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
