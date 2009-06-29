Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id BD9A96B005A
	for <linux-mm@kvack.org>; Mon, 29 Jun 2009 06:56:44 -0400 (EDT)
Subject: Re: kmemleak hexdump proposal
From: Catalin Marinas <catalin.marinas@arm.com>
In-Reply-To: <20090629104553.GA3731@localdomain.by>
References: <20090628173632.GA3890@localdomain.by>
	 <84144f020906290243u7a362465p6b1f566257fa3239@mail.gmail.com>
	 <20090629101917.GA3093@localdomain.by>
	 <1246270774.6364.9.camel@penberg-laptop>
	 <20090629104553.GA3731@localdomain.by>
Content-Type: text/plain
Date: Mon, 29 Jun 2009 11:58:28 +0100
Message-Id: <1246273108.21450.19.camel@pc1117.cambridge.arm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Sergey Senozhatsky <sergey.senozhatsky@mail.by>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2009-06-29 at 13:45 +0300, Sergey Senozhatsky wrote:
> BTW, printing it all the time we can spam kmemleak (in case there are objects sized 2K, 4K and so on).
> That's why I wrote about hexdump=OBJECT_POINTER.

I'm more in favour of an on/off hexdump feature (maybe even permanently
on) and with a limit to the number of bytes it displays. For larger
blocks, the hexdump=OBJECT_POINTER is easily achievable in user space
via /dev/kmem.

My proposal is for an always on hexdump but with no more than 2-3 lines
of hex values. As Pekka said, I should get it into linux-next before the
next merging window.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
