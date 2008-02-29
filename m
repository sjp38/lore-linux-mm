Message-ID: <47C7B463.8050208@cs.helsinki.fi>
Date: Fri, 29 Feb 2008 09:29:39 +0200
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [patch 09/10] slub: Rearrange #ifdef CONFIG_SLUB_DEBUG in calculate_sizes()
References: <20080229043401.900481416@sgi.com> <20080229043553.284904576@sgi.com>
In-Reply-To: <20080229043553.284904576@sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> Group SLUB_DEBUG code together to reduce the number of #ifdefs.
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>

This doesn't just rearrange #ifdefs, it moves the poisoning checks under 
#ifdef too (which is safe). You might want to mention that in the 
changelogs.

Reviewed-by: Pekka Enberg <penberg@cs.helsinki.fi>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
