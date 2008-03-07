Message-ID: <47D15CDF.5060501@keyaccess.nl>
Date: Fri, 07 Mar 2008 16:18:55 +0100
From: Rene Herman <rene.herman@keyaccess.nl>
MIME-Version: 1.0
Subject: Re: [PATCH] [0/13] General DMA zone rework
References: <200803071007.493903088@firstfloor.org>
In-Reply-To: <200803071007.493903088@firstfloor.org>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 07-03-08 10:07, Andi Kleen wrote:

> it to any size needed (upto 2GB currently). The default sizing 
> heuristics are for now the same as in the old code: by default
> all free memory below 16MB is put into the pool (in practice that
> is only ~8MB or so usable because the kernel is loaded there too)

Just a side-comment -- not necessarily, given CONFIG_PHYSICAL_START.

Rene.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
