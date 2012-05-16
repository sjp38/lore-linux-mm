Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id AD2146B0092
	for <linux-mm@kvack.org>; Wed, 16 May 2012 06:17:50 -0400 (EDT)
Message-ID: <4FB37E57.3050209@parallels.com>
Date: Wed, 16 May 2012 14:15:51 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [RFC] SL[AUO]B common code 7/9] slabs: Move kmem_cache_create
 mutex handling to common code
References: <20120514201544.334122849@linux.com> <20120514201612.828855077@linux.com>
In-Reply-To: <20120514201612.828855077@linux.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>

On 05/15/2012 12:15 AM, Christoph Lameter wrote:
> Move the mutex handling into the common kmem_cache_create()
> function.
>
> Then we can also move more checks out of SLAB's kmem_cache_create()
> into the common code.
>
> Signed-off-by: Christoph Lameter<cl@linux.com>
>
> ---
>   mm/slab.c        |   52 +---------------------------------------------------
>   mm/slab_common.c |   41 ++++++++++++++++++++++++++++++++++++++++-
>   mm/slub.c        |   30 ++++++++++++++----------------
>   3 files changed, 55 insertions(+), 68 deletions(-)

I see you are moving a lot of the other tests I mentioned in your other 
e-mail here

Reviewed-by: Glauber Costa <glommer@parallels.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
