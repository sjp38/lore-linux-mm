Date: Tue, 10 Oct 2000 16:07:13 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
Message-ID: <20001010160713.B17671@athlon.random>
References: <39E21CCB.61AC1EBE@kalifornia.com> <E13ik8X-0002qK-00@the-village.bc.nu> <20001010043802.D3386@parcelfarce.linux.theplanet.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20001010043802.D3386@parcelfarce.linux.theplanet.co.uk>; from prumpf@parcelfarce.linux.theplanet.co.uk on Tue, Oct 10, 2000 at 04:38:02AM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Philipp Rumpf <prumpf@parcelfarce.linux.theplanet.co.uk>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, david+validemail@kalifornia.com, mingo@elte.hu, Byron Stanoszek <gandalf@winds.org>, Rik van Riel <riel@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Oct 10, 2000 at 04:38:02AM +0100, Philipp Rumpf wrote:
> Init should never die.  If we get to do_exit in init we'll panic which is
> the right thing to do (reboot on critical systems).

If the page fault can fail with OOM on init, init will get a SIGSEGV while
running a signal handler (copy-user will return -EFAULT regardless it was an
oom or a real segfault) and it _won't_ panic and the system is unusable.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
