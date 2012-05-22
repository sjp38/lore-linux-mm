Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 3DC5D6B0083
	for <linux-mm@kvack.org>; Tue, 22 May 2012 11:29:23 -0400 (EDT)
Message-ID: <4FBBB059.1060903@parallels.com>
Date: Tue, 22 May 2012 19:27:21 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] slab+slob: dup name string
References: <1337680298-11929-1-git-send-email-glommer@parallels.com> <alpine.DEB.2.00.1205220857380.17600@router.home>
In-Reply-To: <alpine.DEB.2.00.1205220857380.17600@router.home>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>

On 05/22/2012 05:58 PM, Christoph Lameter wrote:
> On Tue, 22 May 2012, Glauber Costa wrote:
>
>> [ v2: Also dup string for early caches, requested by David Rientjes ]
>
> kstrdups that early could cause additional issues. Its better to leave
> things as they were.
>

For me is really all the same. But note that before those kstrdups, we 
do a bunch of kmallocs as well already. (ex:

/* 4) Replace the bootstrap head arrays */
{
	struct array_cache *ptr;

	ptr = kmalloc(sizeof(struct arraycache_init), GFP_NOWAIT);

Which other point of issues do you see besides the memory allocation 
done by strdup?

I agree with your comment that we shouldn't worry about those caches, 
because only init code uses it.

Weather or not David's concern of wanting to delete those caches some 
day is valid, I'll leave up to you guys to decide

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
