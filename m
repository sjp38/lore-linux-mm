Date: Wed, 19 Sep 2001 14:55:34 -0700 (PDT)
Message-Id: <20010919.145534.104033668.davem@redhat.com>
Subject: Re: broken VM in 2.4.10-pre9
From: "David S. Miller" <davem@redhat.com>
In-Reply-To: <m1elp2g8vd.fsf@frodo.biederman.org>
References: <E15jnIB-0003gh-00@the-village.bc.nu>
	<m1elp2g8vd.fsf@frodo.biederman.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ebiederm@xmission.com
Cc: alan@lxorguk.ukuu.org.uk, phillips@bonn-fries.net, rfuller@nsisoftware.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

   That I think is a significant cost.

My own personal feeling, after having tried to implement a much
lighter weight scheme involving "anon areas", is that reverse maps or
something similar should be looked at as a latch ditch effort.

We are tons faster than anyone else in fork/exec/exit precisely
because we keep track of so little state for anonymous pages.

Later,
David S. Miller
davem@redhat.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
