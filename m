Date: Tue, 10 Oct 2000 04:38:02 +0100
From: Philipp Rumpf <prumpf@parcelfarce.linux.theplanet.co.uk>
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
Message-ID: <20001010043802.D3386@parcelfarce.linux.theplanet.co.uk>
References: <39E21CCB.61AC1EBE@kalifornia.com> <E13ik8X-0002qK-00@the-village.bc.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <E13ik8X-0002qK-00@the-village.bc.nu>; from alan@lxorguk.ukuu.org.uk on Mon, Oct 09, 2000 at 10:07:04PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: david+validemail@kalifornia.com, mingo@elte.hu, Andrea Arcangeli <andrea@suse.de>, Byron Stanoszek <gandalf@winds.org>, Rik van Riel <riel@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> If init dies the kernel hangs solid anyway

Init should never die.  If we get to do_exit in init we'll panic which is
the right thing to do (reboot on critical systems).
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
