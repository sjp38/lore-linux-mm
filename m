Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 47DD46B024A
	for <linux-mm@kvack.org>; Fri, 22 Jun 2012 14:34:29 -0400 (EDT)
Received: by obhx4 with SMTP id x4so3012372obh.14
        for <linux-mm@kvack.org>; Fri, 22 Jun 2012 11:34:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAAmzW4OuyCJVEHd823LvN3+uz=MN-4HGYyw8pbSUvhBN79wSjQ@mail.gmail.com>
References: <1339176197-13270-1-git-send-email-js1304@gmail.com>
	<1339176197-13270-4-git-send-email-js1304@gmail.com>
	<alpine.DEB.2.00.1206081403380.28466@router.home>
	<CAAmzW4OuyCJVEHd823LvN3+uz=MN-4HGYyw8pbSUvhBN79wSjQ@mail.gmail.com>
Date: Sat, 23 Jun 2012 03:34:27 +0900
Message-ID: <CAAmzW4MKY7rgmQtxbe+AAeZ2meeiirsso9iasif1L7DfcYghYQ@mail.gmail.com>
Subject: Re: [PATCH 4/4] slub: deactivate freelist of kmem_cache_cpu all at
 once in deactivate_slab()
From: JoonSoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

2012/6/10 JoonSoo Kim <js1304@gmail.com>:
> 2012/6/9 Christoph Lameter <cl@linux.com>:
>> On Sat, 9 Jun 2012, Joonsoo Kim wrote:
>>
>>> Current implementation of deactivate_slab() which deactivate
>>> freelist of kmem_cache_cpu one by one is inefficient.
>>> This patch changes it to deactivate freelist all at once.
>>> But, there is no overall performance benefit,
>>> because deactivate_slab() is invoked infrequently.
>>
>> Hmm, deactivate freelist can race with slab_free. Need to look at this in
>> detail.
>
> Implemented logic is nearly same as previous one.
> I just merge first step of previous deactivate_slab() with second one.
> In case of failure of cmpxchg_double_slab(), reloading page->freelist,
> page->counters and recomputing inuse
> ensure that race with slab_free() cannot be possible.
> In case that we need a lock, try to get a lock before invoking
> cmpxchg_double_slab(),
> so race with slab_free cannot be occured too.
>
> Above is my humble opinion, please give me some comments.

Hi Pekka and Christoph.
Could you give me some comments about this, please?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
