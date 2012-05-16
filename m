Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id B49846B004D
	for <linux-mm@kvack.org>; Wed, 16 May 2012 03:54:44 -0400 (EDT)
Message-ID: <4FB35CCD.8070100@parallels.com>
Date: Wed, 16 May 2012 11:52:45 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [RFC] SL[AUO]B common code 2/9] [slab]: Use page struct fields
 instead of casting
References: <20120514201544.334122849@linux.com> <20120514201609.990631220@linux.com>
In-Reply-To: <20120514201609.990631220@linux.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>

On 05/15/2012 12:15 AM, Christoph Lameter wrote:
> Add fields to the page struct so that it is properly documented that
> slab overlays the lru fields.
>
> This cleans up some casts in slab.
>
> Signed-off-by: Christoph Lameter<cl@linux.com>
Reviewed-by: Glauber Costa <glommer@parallels.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
