Date: Tue, 26 Sep 2000 07:17:52 -0600
From: yodaiken@fsmlabs.com
Subject: Re: the new VMt
Message-ID: <20000926071752.A22876@hq.fsmlabs.com>
References: <20000925143523.B19257@hq.fsmlabs.com> <E13df92-0005Zp-00@the-village.bc.nu> <20000925150744.A20586@hq.fsmlabs.com> <20000926105423.D1638@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20000926105423.D1638@redhat.com>; from Stephen C. Tweedie on Tue, Sep 26, 2000 at 10:54:23AM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: yodaiken@fsmlabs.com, Alan Cox <alan@lxorguk.ukuu.org.uk>, Jamie Lokier <lk@tantalophile.demon.co.uk>, mingo@elte.hu, Andrea Arcangeli <andrea@suse.de>, Marcelo Tosatti <marcelo@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 26, 2000 at 10:54:23AM +0100, Stephen C. Tweedie wrote:
> Beancounter is a framework for user-level accounting.  _What_ you
> account is up to the callers.  Maybe this has been a miscommunication,
> but beancounter is all about allowing callers to account for stuff
> before allocation, not about having the page allocation functions
> themselves enforce quotas.


per-user and system-wide and per-process quotas are one thing, a
pre-allocate-and-then-allocate generic scheme seems to me to be a error prone
way of getting there. In particular, I think it is dangerous to have a pre-count that
is approximately tethered to the thing it is counting -- in the memory allocation 
we were discussing, you need to make sure that the pre-allocations are for memory that
is really going to be allocated soon and that it is later correlated with free in 
some way.  

So, to me, a quota bounded allocate_page_table(process_id) makes much more sense then 
pre-allocate counting, or, even worse, a "smart" kmalloc that never fails.
If the problem is unaccounted for page-tables then account for
page tables and return a  -EYOURPROCESSISOUTOFCONTROL so that calling kernel code
can take the responsible action. 
                   

-- 
---------------------------------------------------------
Victor Yodaiken 
Finite State Machine Labs: The RTLinux Company.
 www.fsmlabs.com  www.rtlinux.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
