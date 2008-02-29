Message-ID: <47C7BCBB.5030509@cs.helsinki.fi>
Date: Fri, 29 Feb 2008 10:05:15 +0200
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [patch 01/10] Revert "unique end pointer" patch
References: <20080229043401.900481416@sgi.com> <20080229043551.357047304@sgi.com>
In-Reply-To: <20080229043551.357047304@sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> This only made sense for the alternate fastpath which was reverted last week.
> 
> Mathieu is working on a new version that addresses the fastpath issues but that
> new code first needs to go through mm and it is not clear if we need the
> unique end pointers with his new scheme.
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>

Reviewed-by: Pekka Enberg <penberg@cs.helsinki.fi>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
