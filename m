Date: Mon, 10 Nov 2003 15:42:32 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.6.0-test9-mm2 - AIO tests still gets slab corruption
Message-Id: <20031110154232.55eb9b10.akpm@osdl.org>
In-Reply-To: <1068505605.2042.11.camel@ibm-c.pdx.osdl.net>
References: <20031104225544.0773904f.akpm@osdl.org>
	<1068505605.2042.11.camel@ibm-c.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel McNeil <daniel@osdl.org>
Cc: suparna@in.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-aio@kvack.org
List-ID: <linux-mm.kvack.org>

Daniel McNeil <daniel@osdl.org> wrote:
>
> Andrew,
> 
> test9-mm2 is still getting slab corruption with AIO:

Why?

> Maximal retry count.  Bytes done 0
> Slab corruption: start=dc70f91c, expend=dc70f9eb, problemat=dc70f91c
> Last user: [<c0192fa3>](__aio_put_req+0xbf/0x200)
> Data: 00 01 10 00 00 02 20 00 *********6C ******************************A5
> Next: 71 F0 2C .A3 2F 19 C0 71 F0 2C .********************
> slab error in check_poison_obj(): cache `kiocb': object was modified after freeing
> 
> With suparna's retry-based-aio-dio patch, there are no kernel messages
> and the tests do not see any uninitialized data.
> 
> Any reason not to add suparna's patch to -mm to fix these problems?

It relies on infrastructure which is not present in Linus's kernel.  We
should only be interested in fixing mainline 2.6.x.

Furthermore I'd like to see the direct-vs-buffered locking fixes fully
implemented against Linus's tree, not -mm.  They're almost there, but are
not quite complete.  Running off and making it dependent on the retry
infrastructure is not really helpful.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
