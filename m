From: David Mosberger <davidm@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <15927.31346.6892.154372@napali.hpl.hp.com>
Date: Tue, 28 Jan 2003 22:53:38 -0800
Subject: Re: Linus rollup
In-Reply-To: <20030128220729.1f61edfe.akpm@digeo.com>
References: <20030128220729.1f61edfe.akpm@digeo.com>
Reply-To: davidm@hpl.hp.com
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: Russell King <rmk@arm.linux.org.uk>, Andi Kleen <ak@muc.de>, "David S. Miller" <davem@redhat.com>, David Mosberger <davidm@napali.hpl.hp.com>, Anton Blanchard <anton@samba.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The patch looks good to me.  I applied it on top of 2.5.59+ia64 and it
checked out fine on the Ski simulator and a dual-Itanium2 zx6000
workstation.

Thanks,

	--david

>>>>> On Tue, 28 Jan 2003 22:07:29 -0800, Andrew Morton <akpm@digeo.com> said:

  Andrew> Gents,

  Andrew> I've sifted out all the things which I intend to send to the
  Andrew> boss soon.  It would be good if you could perform some quick
  Andrew> non-ia32 testing please.

  Andrew> Possible breakage would be in the new frlock-for-xtime_lock
  Andrew> code and the get_order() cleanup.

  Andrew> The frlock code is showing nice speedups, but I think the
  Andrew> main reason we want this is to fix the problem wherein an
  Andrew> application spinning on gettimeofday() can make time stop.

  Andrew> It's all at

  Andrew> http://www.zip.com.au/~akpm/linux/patches/2.5/2.5.59/2.5.59-lt1/

  Andrew> Thanks.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
