Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id CF6A06B0089
	for <linux-mm@kvack.org>; Tue,  4 Jan 2011 23:53:05 -0500 (EST)
Received: by iyj17 with SMTP id 17so14605540iyj.14
        for <linux-mm@kvack.org>; Tue, 04 Jan 2011 20:53:04 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110104161805.GE3120@balbir.in.ibm.com>
References: <cover.1293982522.git.minchan.kim@gmail.com>
	<20110104161805.GE3120@balbir.in.ibm.com>
Date: Wed, 5 Jan 2011 13:53:04 +0900
Message-ID: <AANLkTinSuEF-+CCiCyoQbMfMMUJyQAw5JQB8iNrkHgmX@mail.gmail.com>
Subject: Re: [PATCH v2 0/7] Change page reference handling semantic of page cache
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>
List-ID: <linux-mm.kvack.org>

Hi Balbir,

On Wed, Jan 5, 2011 at 1:18 AM, Balbir Singh <balbir@linux.vnet.ibm.com> wr=
ote:
> * MinChan Kim <minchan.kim@gmail.com> [2011-01-03 00:44:29]:
>
>> Now we increases page reference on add_to_page_cache but doesn't decreas=
e it
>> in remove_from_page_cache. Such asymmetric makes confusing about
>> page reference so that caller should notice it and comment why they
>> release page reference. It's not good API.
>>
>> Long time ago, Hugh tried it[1] but gave up of reason which
>> reiser4's drop_page had to unlock the page between removing it from
>> page cache and doing the page_cache_release. But now the situation is
>> changed. I think at least things in current mainline doesn't have any
>> obstacles. The problem is fs or somethings out of mainline.
>> If it has done such thing like reiser4, this patch could be a problem bu=
t
>> they found it when compile time since we remove remove_from_page_cache.
>>
>> [1] http://lkml.org/lkml/2004/10/24/140
>>
>> The series configuration is following as.
>>
>> [1/7] : This patch introduces new API delete_from_page_cache.
>> [2,3,4,5/7] : Change remove_from_page_cache with delete_from_page_cache.
>> Intentionally I divide patch per file since someone might have a concern
>> about releasing page reference of delete_from_page_cache in
>> somecase (ex, truncate.c)
>> [6/7] : Remove old API so out of fs can meet compile error when build ti=
me
>> and can notice it.
>> [7/7] : Change __remove_from_page_cache with __delete_from_page_cache, t=
oo.
>> In this time, I made all-in-one patch because it doesn't change old beha=
vior
>> so it has no concern. Just clean up patch.
>>
>
> Could you please describe any testing done, was it mostly functional?

I didn't test it since I think it's okay as a code review.
Do you find any faults or guess it?
Anyway, I should have tested it before sending patches.

we are now -rc8 and Andrew doesn't held a patch.
So I will test it until he grab a patch.

Thanks,

>
> --
> =A0 =A0 =A0 =A0Three Cheers,
> =A0 =A0 =A0 =A0Balbir
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
