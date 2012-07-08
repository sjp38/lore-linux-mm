Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 8226E6B0083
	for <linux-mm@kvack.org>; Sun,  8 Jul 2012 12:19:10 -0400 (EDT)
Received: by obhx4 with SMTP id x4so17381416obh.14
        for <linux-mm@kvack.org>; Sun, 08 Jul 2012 09:19:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1207061008560.28648@router.home>
References: <1340389359-2407-1-git-send-email-js1304@gmail.com>
	<1340389359-2407-3-git-send-email-js1304@gmail.com>
	<alpine.DEB.2.00.1207050924330.4138@router.home>
	<CAAmzW4NJyX9e_dMyJBA5zDiVYVmL1vbUkaRHNoSbbhDZWW7iMg@mail.gmail.com>
	<alpine.DEB.2.00.1207060928580.26790@router.home>
	<CAAmzW4P941qeKy6UH079r73zR5VjUeNZNB53Mi4wiHE28f==gg@mail.gmail.com>
	<alpine.DEB.2.00.1207061008560.28648@router.home>
Date: Mon, 9 Jul 2012 01:19:09 +0900
Message-ID: <CAAmzW4PzJiBFDR3rKwVBn0Ex5cCR=qai6SA9_SbVH-psuh6nOQ@mail.gmail.com>
Subject: Re: [PATCH 3/3] slub: release a lock if freeing object with a lock is
 failed in __slab_free()
From: JoonSoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

2012/7/7 Christoph Lameter <cl@linux.com>:
> On Fri, 6 Jul 2012, JoonSoo Kim wrote:
>
>> >> At CPU2, we don't need lock anymore, because this slab already in partial list.
>> >
>> > For that scenario we could also simply do a trylock there and redo
>> > the loop if we fail. But still what guarantees that another process will
>> > not modify the page struct between fetching the data and a successful
>> > trylock?
>>
>>
>> I'm not familiar with English, so take my ability to understand into
>> consideration.
>
> I have a hard time understanding what you want to accomplish here.
>
>> we don't need guarantees that another process will not modify
>> the page struct between fetching the data and a successful trylock.
>
> No we do not need that since the cmpxchg will then fail.
>
> Maybe it would be useful to split this patch into two?
>
> One where you introduce the dropping of the lock and the other where you
> get rid of certain code paths?
>

Dropping of the lock is need for getting rid of certain code paths.
So, I can't split this patch into two.

Sorry for confusing all the people.
I think that I don't explain my purpose well.
I will prepare new version in which I explain purpose of patch better.

Thanks for kind review.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
