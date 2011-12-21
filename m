Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 018D86B0062
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 02:10:56 -0500 (EST)
Date: Wed, 21 Dec 2011 07:10:39 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [Resend] 3.2-rc6+: Reported regressions from 3.0 and 3.1
Message-ID: <20111221071039.GH23916@ZenIV.linux.org.uk>
References: <201112210054.46995.rjw@sisk.pl>
 <CA+55aFzee7ORKzjZ-_PrVy796k2ASyTe_Odz=ji7f1VzToOkKw@mail.gmail.com>
 <4EF15F42.4070104@oracle.com>
 <CA+55aFx=B9adsTR=-uYpmfJnQgdGN+1aL0KUabH5bSY6YcwO7Q@mail.gmail.com>
 <alpine.LSU.2.00.1112202213310.3987@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1112202213310.3987@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Dave Kleikamp <dave.kleikamp@oracle.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Dave Kleikamp <shaggy@kernel.org>, jfs-discussion@lists.sourceforge.net, Kernel Testers List <kernel-testers@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Maciej Rutecki <maciej.rutecki@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Florian Mickler <florian@mickler.org>, davem@davemloft.net, linux-mm@kvack.org

On Tue, Dec 20, 2011 at 10:15:00PM -0800, Hugh Dickins wrote:

> Acked-by: Hugh Dickins <hughd@google.com>
> 
> from me (and add_to_page_cache_locked does the masking of inappropriate
> bits when passing on down, so no need to worry about that aspect).

I was grepping for possibilities of that hitting us right now...  OK,
rigth you are.

Acked-by: Al Viro <viro@zeniv.linux.org.uk>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
