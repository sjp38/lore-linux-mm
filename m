Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id BE0A66B004D
	for <linux-mm@kvack.org>; Mon, 21 May 2012 15:21:24 -0400 (EDT)
Message-ID: <4FBA9536.1020502@parallels.com>
Date: Mon, 21 May 2012 23:19:18 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [RFC] Common code 09/12] slabs: Extract a common function for
 kmem_cache_destroy
References: <20120518161906.207356777@linux.com> <20120518161932.147485968@linux.com> <4FBA0C2D.3000101@parallels.com> <alpine.DEB.2.00.1205211312270.30649@router.home>
In-Reply-To: <alpine.DEB.2.00.1205211312270.30649@router.home>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Joonsoo Kim <js1304@gmail.com>, Alex Shi <alex.shi@intel.com>

On 05/21/2012 10:13 PM, Christoph Lameter wrote:
>> So unless I am missing something, it seems to me the correct code would be:
>> >
>> >  s->refcount--;
>> >  if (!s->refcount)
>> >       return kmem_cache_close;
>> >  return 0;
>> >
>> >  And while we're on that, that makes the sequence list_del() ->  if it fails ->
>> >  list_add() in the common kmem_cache_destroy a bit clumsy. Aliases will be
>> >  re-added to the list quite frequently. Not that it is a big problem, but
>> >  still...
> True but this is just an intermediate step. Ultimately the series will
> move sysfs processing into slab_common.c and then this is going away.
>

But until then, people bisecting into this patch will find a broken 
state, right?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
