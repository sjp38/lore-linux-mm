Received: from mail.intermedia.net ([207.5.44.129])
	by kvack.org (8.8.7/8.8.7) with SMTP id NAA24032
	for <linux-mm@kvack.org>; Mon, 24 May 1999 13:26:29 -0400
Received: from [134.96.127.159] by mail.colorfullife.com (NTMail 3.03.0017/1.abcr) with ESMTP id la382211 for <linux-mm@kvack.org>; Mon, 24 May 1999 10:26:43 -0700
Message-ID: <37498A69.FF40CFE3@colorfullife.com>
Date: Mon, 24 May 1999 19:20:41 +0200
From: Manfred Spraul <manfreds@colorfullife.com>
Reply-To: masp0008@stud.uni-sb.de
MIME-Version: 1.0
Subject: Re: [PATCHES]
References: <Pine.LNX.3.96.990523171206.21583A-100000@chiara.csoma.elte.hu>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@chiara.csoma.elte.hu>
Cc: "Eric W. Biederman" <ebiederm+eric@ccr.net>, Linus Torvalds <torvalds@transmeta.com>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ingo Molnar wrote:
> on my box the page cache is already completely parallel on SMP,
> we drop the kernel lock on entry into page-cache routines and
> re-lock it only if we call filesystem-specific code or
> buffer-cache code.

How have you called the 'release_kernel_lock()' function?

I found several lengthy operations in the kernel which
should also release the kernel lock.
(the slowest: clear_page() when called by get_free_page(GFP_WAIT))

--
	Manfred


--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
