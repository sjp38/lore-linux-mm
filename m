Date: Sat, 01 Nov 2008 21:42:54 -0700 (PDT)
Message-Id: <20081101.214254.178222451.davem@davemloft.net>
Subject: Re: 2.6.28-rc2: Unable to handle kernel paging request at
 iov_iter_copy_from_user_atomic
From: David Miller <davem@davemloft.net>
In-Reply-To: <a4423d670811012102m3fdd245apbe0a310b4890f958@mail.gmail.com>
References: <a4423d670811010723u3b271fcaxa7d3bdb251a8b246@mail.gmail.com>
	<Pine.LNX.4.64.0811011837110.20211@blonde.site>
	<a4423d670811012102m3fdd245apbe0a310b4890f958@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: "Alexander Beregalov" <a.beregalov@gmail.com>
Date: Sun, 2 Nov 2008 07:02:40 +0300
Return-Path: <owner-linux-mm@kvack.org>
To: a.beregalov@gmail.com
Cc: hugh@veritas.com, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Should we fix also sparc32?

Sparc32 uses a different scheme for all of this stuff.
I don't think your patch will even compile.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
