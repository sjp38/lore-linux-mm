Message-ID: <47B69B01.6020003@cs.helsinki.fi>
Date: Sat, 16 Feb 2008 10:12:49 +0200
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [patch 1/8] slub: rename slab_objects to show_slab_objects
References: <20080215230811.635628223@sgi.com> <20080215230853.165783772@sgi.com>
In-Reply-To: <20080215230853.165783772@sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> The sysfs callback is better named show_slab_objects since it is always
> called from the xxx_show callbacks. We need the name for other purposes
> later.
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>

Reviewed-by: Pekka Enberg <penberg@cs.helsinki.fi>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
