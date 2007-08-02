Date: Thu, 2 Aug 2007 16:08:51 +0200 (CEST)
From: Jan Engelhardt <jengelh@computergmbh.de>
Subject: Re: [PATCH] type safe allocator
In-Reply-To: <1186063605.8085.82.camel@tara.firmix.at>
Message-ID: <Pine.LNX.4.64.0708021608010.24572@fbirervta.pbzchgretzou.qr>
References: <E1IGAAI-0006K6-00@dorka.pomaz.szeredi.hu>
 <E1IGYuK-0001Jj-00@dorka.pomaz.szeredi.hu>  <b6fcc0a0708020504j7588061fq7e70a50499dcbdfe@mail.gmail.com>
  <1186062476.12034.115.camel@twins> <1186063605.8085.82.camel@tara.firmix.at>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Bernd Petrovitsch <bernd@firmix.at>
Cc: Peter Zijlstra <peterz@infradead.org>, Alexey Dobriyan <adobriyan@gmail.com>, Miklos Szeredi <miklos@szeredi.hu>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Aug 2 2007 16:06, Bernd Petrovitsch wrote:
>> thrice in some cases like alloc_struct(struct task_struct, GFP_KERNEL)
>
>Save the explicit "struct" and put it into the macro (and force people
>to not use typedefs).
>
>#define alloc_struct(type, flags) ((type *)kmalloc(sizeof(struct type), (flags)))

#define alloc_struct(type, flags) ((struct type *)kmalloc(sizeof(struct type), (flags)))

>Obious drawback: We may need alloc_union().
>SCNR.

And we still don't have something to allocate a bunch of ints.
[kmalloc(sizeof(int)*5,GFP)]


	Jan
-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
