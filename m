Subject: Re: [PATCH 2.6.13] lockless pagecache 2/7
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
In-Reply-To: <4318FF2B.6000805@yahoo.com.au>
References: <4317F071.1070403@yahoo.com.au> <4317F0F9.1080602@yahoo.com.au>
	 <4317F136.4040601@yahoo.com.au>
	 <1125666486.30867.11.camel@localhost.localdomain>
	 <p73k6hzqk1w.fsf@verdi.suse.de>  <4318C28A.5010000@yahoo.com.au>
	 <1125705471.30867.40.camel@localhost.localdomain>
	 <4318FF2B.6000805@yahoo.com.au>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: Sat, 03 Sep 2005 18:31:36 +0100
Message-Id: <1125768697.14987.7.camel@localhost.localdomain>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andi Kleen <ak@suse.de>, Linux Memory Management <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Sad, 2005-09-03 at 11:40 +1000, Nick Piggin wrote:
> We'll see how things go. I'm fairly sure that for my usage it will
> be a win even if it is costly. It is replacing an atomic_inc_return,
> and a read_lock/read_unlock pair.

Make sure you bench both AMD and Intel - I'd expect it to be a big loss
on AMD because the AMD stuff will perform atomic locked operations very
efficiently if they are already exclusive on this CPU or a prefetch_w()
on them was done 200+ clocks before.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
