Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id D70516B00A8
	for <linux-mm@kvack.org>; Fri, 24 Aug 2012 12:28:58 -0400 (EDT)
Received: by obhx4 with SMTP id x4so5621338obh.14
        for <linux-mm@kvack.org>; Fri, 24 Aug 2012 09:28:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <00000139596a800b-875d7863-23ac-44a5-8710-ea357f3df8a8-000000@email.amazonses.com>
References: <1345824303-30292-1-git-send-email-js1304@gmail.com>
	<1345824303-30292-2-git-send-email-js1304@gmail.com>
	<00000139596a800b-875d7863-23ac-44a5-8710-ea357f3df8a8-000000@email.amazonses.com>
Date: Sat, 25 Aug 2012 01:28:58 +0900
Message-ID: <CAAmzW4ORnSLMdhVPmYPpeEJ=P1rrpz1LOibOYWQJgOYQxmDhuA@mail.gmail.com>
Subject: Re: [PATCH 2/2] slub: correct the calculation of the number of cpu
 objects in get_partial_node
From: JoonSoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

2012/8/25 Christoph Lameter <cl@linux.com>:
> On Sat, 25 Aug 2012, Joonsoo Kim wrote:
>
>> index d597530..c96e0e4 100644
>> --- a/mm/slub.c
>> +++ b/mm/slub.c
>> @@ -1538,6 +1538,7 @@ static void *get_partial_node(struct kmem_cache *s,
>>  {
>>       struct page *page, *page2;
>>       void *object = NULL;
>> +     int cpu_slab_objects = 0, pobjects = 0;
>
> We really need be clear here.
>
> One counter is for the numbe of objects in the per cpu slab and the other
> for the objects in tbhe per cpu partial lists.
>
> So I think the first name is ok. Second should be similar
>
> cpu_partial_objects?
>

Okay! It looks good.
But, when using "cpu_partial_objects", I have a coding style problem.

                if (kmem_cache_debug(s)
                        || cpu_slab_objects + cpu_partial_objects
                                                > s->max_cpu_object / 2)

Do you have any good idea?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
