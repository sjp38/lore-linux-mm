Date: Mon, 9 Oct 2000 14:21:05 -0700 (PDT)
From: jg@pa.dec.com (Jim Gettys)
Message-Id: <200010092121.OAA01924@pachyderm.pa.dec.com>
In-Reply-To: <20001009225822.A21401@gruyere.muc.suse.de>
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Linus Torvalds <torvalds@transmeta.com>, Ingo Molnar <mingo@elte.hu>, Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@conectiva.com.br>, Byron Stanoszek <gandalf@winds.org>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> Sender: linux-kernel-owner@vger.kernel.org
> From: "Andi Kleen" <ak@suse.de>
> Date: 	Mon, 9 Oct 2000 22:58:22 +0200
> To: Linus Torvalds <torvalds@transmeta.com>
> Cc: Andi Kleen <ak@suse.de>, Ingo Molnar <mingo@elte.hu>,
>         Andrea Arcangeli <andrea@suse.de>,
>         Rik van Riel <riel@conectiva.com.br>,
>         Byron Stanoszek <gandalf@winds.org>,
>         MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
> Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
> -----
> On Mon, Oct 09, 2000 at 01:52:21PM -0700, Linus Torvalds wrote:
> > One thing we _can_ (and probably should do) is to do a per-user memory
> > pressure thing - we have easy access to the "struct user_struct" (every
> > process has a direct pointer to it), and it should not be too bad to
> > maintain a per-user "VM pressure" counter.
> >
> > Then, instead of trying to use heuristics like "does this process have
> > children" etc, you'd have things like "is this user a nasty user", which
> > is a much more valid thing to do and can be used to find people who fork
> > tons of processes that are mid-sized but use a lot of memory due to just
> > being many..
> 
> Would not help much when "they" eat your memory by loading big bitmaps
> into the X server which runs as root (it seems there are many programs
> which are very good at this particular DOS ;)
> 

This is generic to any server program, not unique to X.

Sounds like one needs in addition some mechanism for servers to "charge" clients for
consumption. X certainly knows on behalf of which connection resources
are created; the OS could then transfer this back to the appropriate client
(at least when on machine).

					- Jim

--
Jim Gettys
Technology and Corporate Development
Compaq Computer Corporation
jg@pa.dec.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
