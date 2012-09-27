Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 6B4426B005D
	for <linux-mm@kvack.org>; Thu, 27 Sep 2012 12:41:51 -0400 (EDT)
Message-ID: <506480FB.40802@parallels.com>
Date: Thu, 27 Sep 2012 20:38:19 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/4] sl[au]b: process slabinfo_show in common code
References: <1348756660-16929-1-git-send-email-glommer@parallels.com> <1348756660-16929-5-git-send-email-glommer@parallels.com> <0000013a08443b02-5715bfe6-9c47-49c5-a951-8a48cc432e42-000000@email.amazonses.com>
In-Reply-To: <0000013a08443b02-5715bfe6-9c47-49c5-a951-8a48cc432e42-000000@email.amazonses.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>

On 09/27/2012 07:07 PM, Christoph Lameter wrote:
> On Thu, 27 Sep 2012, Glauber Costa wrote:
> 
>> --- a/mm/slab_common.c
>> +++ b/mm/slab_common.c
>> @@ -239,7 +239,23 @@ static void s_stop(struct seq_file *m, void *p)
>>
>>  static int s_show(struct seq_file *m, void *p)
>>  {
>> -	return slabinfo_show(m, p);
>> +	struct kmem_cache *s = list_entry(p, struct kmem_cache, list);
>> +	struct slabinfo sinfo;
>> +
>> +	memset(&sinfo, 0, sizeof(sinfo));
>> +	get_slabinfo(s, &sinfo);
> 
> Could get_slabinfo() also set the objects per slab etc in some additional
> field in struct slabinfo? Then we can avoid the exporting of the oo_
> functions and we do not need the cache_order() etc functions.
> 
Yes. As a matter of fact, I first implemented it this way, and later
switched. I was anticipating that people would be likely to point out
that those properties are directly derivable from the caches, and it
would be better to just get them from there.

I am more than happy to stick them in the slabinfo struct.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
