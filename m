Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 37E2E6B004A
	for <linux-mm@kvack.org>; Thu, 21 Oct 2010 22:34:03 -0400 (EDT)
Received: by gxk4 with SMTP id 4so237570gxk.14
        for <linux-mm@kvack.org>; Thu, 21 Oct 2010 19:34:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20101021140105.GA9709@localhost>
References: <1287667701-8081-1-git-send-email-lliubbo@gmail.com>
	<20101021140105.GA9709@localhost>
Date: Fri, 22 Oct 2010 10:34:01 +0800
Message-ID: <AANLkTi=TnFswpyZc874_ydTvVD7Tn67OC9=oL_e=tnp9@mail.gmail.com>
Subject: Re: [PATCH 1/3] page_isolation: codeclean fix comment and rm unneeded
 val init
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kamezawa.hiroyu@jp.fujitsu.com" <kamezawa.hiroyu@jp.fujitsu.com>, "mel@csn.ul.ie" <mel@csn.ul.ie>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, Oct 21, 2010 at 10:01 PM, Wu Fengguang <fengguang.wu@intel.com> wro=
te:
> On Thu, Oct 21, 2010 at 09:28:19PM +0800, Bob Liu wrote:
>> function __test_page_isolated_in_pageblock() return 1 if all pages
>> in the range is isolated, so fix the comment.
>> value pfn will be init in the following loop so rm it.
>
> This is a bit confusing, but the original comment should be intended
> for test_pages_isolated()..

Maybe it used to but now it said "zone->lock must be held before call this"=
,
so it is the comment for __test_page_isolated_in_pageblock() nomore
test_pages_isolated(),
so fix the comment as this patch did.

Thanks.

>
>> Signed-off-by: Bob Liu <lliubbo@gmail.com>
>> ---
>> =C2=A0mm/page_isolation.c | =C2=A0 =C2=A03 +--
>> =C2=A01 files changed, 1 insertions(+), 2 deletions(-)
>>
>> diff --git a/mm/page_isolation.c b/mm/page_isolation.c
>> index 5e0ffd9..4ae42bb 100644
>> --- a/mm/page_isolation.c
>> +++ b/mm/page_isolation.c
>> @@ -86,7 +86,7 @@ undo_isolate_page_range(unsigned long start_pfn, unsig=
ned long end_pfn)
>> =C2=A0 * all pages in [start_pfn...end_pfn) must be in the same zone.
>> =C2=A0 * zone->lock must be held before call this.
>> =C2=A0 *
>> - * Returns 0 if all pages in the range is isolated.
>> + * Returns 1 if all pages in the range is isolated.
>> =C2=A0 */
>> =C2=A0static int
>> =C2=A0__test_page_isolated_in_pageblock(unsigned long pfn, unsigned long=
 end_pfn)
>> @@ -119,7 +119,6 @@ int test_pages_isolated(unsigned long start_pfn, uns=
igned long end_pfn)
>> =C2=A0 =C2=A0 =C2=A0 struct zone *zone;
>> =C2=A0 =C2=A0 =C2=A0 int ret;
>>
>> - =C2=A0 =C2=A0 pfn =3D start_pfn;
>> =C2=A0 =C2=A0 =C2=A0 /*
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0* Note: pageblock_nr_page !=3D MAX_ORDER. The=
n, chunks of free page
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0* is not aligned to pageblock_nr_pages.
>> --
>> 1.5.6.3
>
--=20
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
