Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id C9E176B0028
	for <linux-mm@kvack.org>; Tue,  5 Feb 2013 07:53:17 -0500 (EST)
Message-ID: <5111006A.4070809@imgtec.com>
Date: Tue, 5 Feb 2013 12:51:54 +0000
From: James Hogan <james.hogan@imgtec.com>
MIME-Version: 1.0
Subject: Re: next-20130204 - bisected slab problem to "slab: Common constants
 for kmalloc boundaries"
References: <510FE051.7080107@imgtec.com> <0000013ca6a87485-3f013e82-046c-4374-86d5-67fb85a085f9-000000@email.amazonses.com>
In-Reply-To: <0000013ca6a87485-3f013e82-046c-4374-86d5-67fb85a085f9-000000@email.amazonses.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-next <linux-next@vger.kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, Pekka Enberg <penberg@kernel.org>, Matt
 Mackall <mpm@selenic.com>, linux-mm@kvack.org

Hi Christoph,

On 04/02/13 19:22, Christoph Lameter wrote:
> What are the values of
> 
> MAX_ORDER

10

> PAGE_SHIFT

12

> ARCH_DMA_MINALIGN

64 (it works if changed to 8)

> CONFIG_ZONE_DMA

not defined

Cheers
James

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
