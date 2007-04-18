Message-ID: <4625BDA9.7080106@sw.ru>
Date: Wed, 18 Apr 2007 10:41:45 +0400
From: Pavel Emelianov <xemul@sw.ru>
MIME-Version: 1.0
Subject: Re: [PATCH] Show slab memory usage on OOM and SysRq-M (v2)
References: <4624E8F4.2090200@sw.ru> <1176831473.12599.30.camel@localhost.localdomain>
In-Reply-To: <1176831473.12599.30.camel@localhost.localdomain>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <hansendc@us.ibm.com>
Cc: Andrew Morton <akpm@osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Eric Dumazet <dada1@cosmosbay.com>, Linux MM <linux-mm@kvack.org>, devel@openvz.org, Kirill Korotaev <dev@openvz.org>
List-ID: <linux-mm.kvack.org>

Dave Hansen wrote:
> On Tue, 2007-04-17 at 19:34 +0400, Pavel Emelianov wrote:
>> +#define SHOW_TOP_SLABS 10 
> 
> Real minor nit on this one: SHOW_TOP_SLABS sounds like a bool.  "Should
> I show the top slabs?"
> 
> This might be a bit more clear:
> 
> #define TOP_NR_SLABS_TO_SHOW 10 
> 
> or
> 
> #define NR_SLABS_TO_SHOW 10

Agree :) Will fix in a moment.

> 
> -- Dave
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
