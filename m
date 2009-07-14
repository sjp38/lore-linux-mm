Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 19F7A6B005D
	for <linux-mm@kvack.org>; Tue, 14 Jul 2009 06:03:44 -0400 (EDT)
Subject: Re: kmemleak hexdump proposal
From: Catalin Marinas <catalin.marinas@arm.com>
In-Reply-To: <20090714103356.GA2929@localdomain.by>
References: <20090629201014.GA5414@localdomain.by>
	 <1247566033.28240.46.camel@pc1117.cambridge.arm.com>
	 <20090714103356.GA2929@localdomain.by>
Content-Type: text/plain
Date: Tue, 14 Jul 2009 11:34:01 +0100
Message-Id: <1247567641.28240.51.camel@pc1117.cambridge.arm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Sergey Senozhatsky <sergey.senozhatsky@mail.by>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2009-07-14 at 13:33 +0300, Sergey Senozhatsky wrote:
> On (07/14/09 11:07), Catalin Marinas wrote:
> Am I understand correct that no way for user to on/off hexdump?
> /* no need for atomic_t kmemleak_hex_dump */

Yes. Two lines aren't really too much so we can always have them
displayed.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
