Message-ID: <47B6A4EB.2030206@cs.helsinki.fi>
Date: Sat, 16 Feb 2008 10:55:07 +0200
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [patch 2/8] slub: Add function to determine the amount of objects
 that can reside in a given slab
References: <20080215230811.635628223@sgi.com> <20080215230853.397873101@sgi.com>
In-Reply-To: <20080215230853.397873101@sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> Add a new function that determines the maximum number of objects that a given slab
> can accomodate. At this stage the function always returns the maximum number of objects
> since fallback is not available yet.
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>

Reviewed-by: Pekka Enberg <penberg@cs.helsinki.fi>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
