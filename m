Date: Tue, 28 Jan 2003 23:25:40 -0800 (PST)
Message-Id: <20030128.232540.76615450.davem@redhat.com>
Subject: Re: Linus rollup
From: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030128220729.1f61edfe.akpm@digeo.com>
References: <20030128220729.1f61edfe.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@digeo.com
Cc: rmk@arm.linux.org.uk, ak@muc.de, davidm@napali.hpl.hp.com, anton@samba.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

   I've sifted out all the things which I intend to send to the boss soon.  It
   would be good if you could perform some quick non-ia32 testing please.
   
   Possible breakage would be in the new frlock-for-xtime_lock code and the
   get_order() cleanup.

It all looks fine, I didn't sanity build/boot it on sparc but if
there are any problems they will be minor and I'll just fix it up
when Linus grabs your stuff.

BTW, that:

	do {
		seq = fr_read_begin(...);
		sec = foo;
		usec = bar;
	} while (seq != fr_read_end(...))

loop is duplicated nearly identically perhaps 10 to 15 times, would
be nice to put it in one spot if possible. :-)
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
