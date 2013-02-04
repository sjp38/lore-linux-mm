Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id A3F386B0028
	for <linux-mm@kvack.org>; Mon,  4 Feb 2013 14:22:04 -0500 (EST)
Date: Mon, 4 Feb 2013 19:22:03 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: next-20130204 - bisected slab problem to "slab: Common constants
 for kmalloc boundaries"
In-Reply-To: <510FE051.7080107@imgtec.com>
Message-ID: <0000013ca6a87485-3f013e82-046c-4374-86d5-67fb85a085f9-000000@email.amazonses.com>
References: <510FE051.7080107@imgtec.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Hogan <james.hogan@imgtec.com>
Cc: linux-next <linux-next@vger.kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org

On Mon, 4 Feb 2013, James Hogan wrote:

> I've hit boot problems in next-20130204 on Meta:

Meta is an arch that is not in the tree yet? How would I build for meta?

What are the values of

MAX_ORDER
PAGE_SHIFT
ARCH_DMA_MINALIGN
CONFIG_ZONE_DMA

?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
