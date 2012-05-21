Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id D34686B0081
	for <linux-mm@kvack.org>; Mon, 21 May 2012 05:29:51 -0400 (EDT)
Message-ID: <4FBA0A94.8000803@parallels.com>
Date: Mon, 21 May 2012 13:27:48 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [RFC] Common code 08/12] slabs: list addition move to slab_common
References: <20120518161906.207356777@linux.com> <20120518161931.570041085@linux.com>
In-Reply-To: <20120518161931.570041085@linux.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Joonsoo Kim <js1304@gmail.com>, Alex Shi <alex.shi@intel.com>

On 05/18/2012 08:19 PM, Christoph Lameter wrote:
> Move the code to append the new kmem_cache to the list of slab caches to
> the kmem_cache_create code in the shared code.
>
> This is possible now since the acquisition of the mutex was moved into
> kmem_cache_create().
>
> Signed-off-by: Christoph Lameter<cl@linux.com>
Reviewed-by: Glauber Costa <glommer@parallels.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
