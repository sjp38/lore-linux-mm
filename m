Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 18A306B0081
	for <linux-mm@kvack.org>; Mon, 21 May 2012 05:28:59 -0400 (EDT)
Message-ID: <4FBA0A5F.9000508@parallels.com>
Date: Mon, 21 May 2012 13:26:55 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [RFC] Common code 05/12] slabs: Common definition for boot state
 of the slab allocators
References: <20120518161906.207356777@linux.com> <20120518161929.835778283@linux.com>
In-Reply-To: <20120518161929.835778283@linux.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Joonsoo Kim <js1304@gmail.com>, Alex Shi <alex.shi@intel.com>

On 05/18/2012 08:19 PM, Christoph Lameter wrote:
> All allocators have some sort of support for the bootstrap status.
>
> Setup a common definition for the boot states and make all slab
> allocators use that definition.
>
> Signed-off-by: Christoph Lameter<cl@linux.com>
Reviewed-by: Glauber Costa <glommer@parallels.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
