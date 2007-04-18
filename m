Message-ID: <4625C2A9.6010306@sw.ru>
Date: Wed, 18 Apr 2007 11:03:05 +0400
From: Pavel Emelianov <xemul@sw.ru>
MIME-Version: 1.0
Subject: Re: [PATCH] Show slab memory usage on OOM and SysRq-M (v2)
References: <4624E8F4.2090200@sw.ru> <84144f020704172324u725f6b22u4b1634203d65167c@mail.gmail.com>
In-Reply-To: <84144f020704172324u725f6b22u4b1634203d65167c@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Andrew Morton <akpm@osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Eric Dumazet <dada1@cosmosbay.com>, Linux MM <linux-mm@kvack.org>, devel@openvz.org, Kirill Korotaev <dev@openvz.org>
List-ID: <linux-mm.kvack.org>

Pekka Enberg wrote:
> On 4/17/07, Pavel Emelianov <xemul@sw.ru> wrote:
>> The out_of_memory() function and SysRq-M handler call
>> show_mem() to show the current memory usage state.
> 
> I am still somewhat unhappy about the spinlock, but I don't really

What's wrong with the spinlock? It exists there without my
patch, I just make ++/-- of unatomic variable under this lock :)

> have a better suggestion either. Other than that, looks good to me.
> 
> Acked-by: Pekka Enberg <penberg@cs.helsinki.fi>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
