Message-ID: <47CDA57A.1030809@cs.helsinki.fi>
Date: Tue, 04 Mar 2008 21:39:38 +0200
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: slub statistics: Check the correct value for DEACTIVATE_REMOTE_FREES
References: <Pine.LNX.4.64.0803041132210.17619@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0803041132210.17619@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> From: Christoph Lameter <clameter@sgi.com>
> Subject: slub statistics: Check the correct value for DEACTIVATE_REMOTE_FREES
> 
> The remote frees are in the freelist of the page and not in the
> percpu freelist.

Reviewed-by: Pekka Enberg <penberg@cs.helsinki.fi>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
