Subject: Re: [PATCH 2.6.13] lockless pagecache 2/7
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
In-Reply-To: <4317F136.4040601@yahoo.com.au>
References: <4317F071.1070403@yahoo.com.au> <4317F0F9.1080602@yahoo.com.au>
	 <4317F136.4040601@yahoo.com.au>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: Fri, 02 Sep 2005 14:08:06 +0100
Message-Id: <1125666486.30867.11.camel@localhost.localdomain>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Linux Memory Management <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Gwe, 2005-09-02 at 16:29 +1000, Nick Piggin wrote:
> 2/7
> Implement atomic_cmpxchg for i386 and ppc64. Is there any
> architecture that won't be able to implement such an operation?

i386, sun4c, ....

Yeah quite a few. I suspect most MIPS also would have a problem in this
area.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
