Date: Mon, 25 Sep 2000 11:51:39 -0600
From: yodaiken@fsmlabs.com
Subject: Re: the new VMt
Message-ID: <20000925115139.A14999@hq.fsmlabs.com>
References: <Pine.LNX.4.21.0009251714480.9122-100000@elte.hu> <E13da01-00057k-00@the-village.bc.nu> <20000925164249.G2615@redhat.com> <20000925105247.A13935@hq.fsmlabs.com> <20000925191829.A14612@pcep-jamie.cern.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20000925191829.A14612@pcep-jamie.cern.ch>; from Jamie Lokier on Mon, Sep 25, 2000 at 07:18:29PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jamie Lokier <lk@tantalophile.demon.co.uk>
Cc: yodaiken@fsmlabs.com, "Stephen C. Tweedie" <sct@redhat.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, mingo@elte.hu, Andrea Arcangeli <andrea@suse.de>, Marcelo Tosatti <marcelo@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 25, 2000 at 07:18:29PM +0200, Jamie Lokier wrote:
> yodaiken@fsmlabs.com wrote:
> >    walk = out;
> >         while(nfds > 0) {
> >                 poll_table *tmp = (poll_table *) __get_free_page(GFP_KERNEL);
> >                 if (!tmp) {
> 
> Shouldn't this be GFP_USER?  (Which would also conveniently fix the
> problem Victor's pointing out...)

It should probably be GFP_ATOMIC, if I understand the mm right. 

The algorithm for requesting a collection of reources and freeing all of them
 on failure is simple, fast, and robust. 


              

-- 
---------------------------------------------------------
Victor Yodaiken 
Finite State Machine Labs: The RTLinux Company.
 www.fsmlabs.com  www.rtlinux.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
