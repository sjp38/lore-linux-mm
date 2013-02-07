Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 4C7146B0005
	for <linux-mm@kvack.org>; Wed,  6 Feb 2013 20:55:20 -0500 (EST)
Message-ID: <51130927.7050805@cn.fujitsu.com>
Date: Thu, 07 Feb 2013 09:53:43 +0800
From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: accurately document nr_free_*_pages functions with
 code comments
References: <5112138C.7040902@cn.fujitsu.com> <5112FB96.1040606@infradead.org>
In-Reply-To: <5112FB96.1040606@infradead.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, mgorman@suse.de, minchan@kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

=E4=BA=8E 2013=E5=B9=B402=E6=9C=8807=E6=97=A5 08:55, Randy Dunlap =E5=86=99=
=E9=81=93:
> On 02/06/13 00:25, Zhang Yanfei wrote:
>> Functions nr=5Ffree=5Fzone=5Fpages, nr=5Ffree=5Fbuffer=5Fpages and nr=5F=
free=5Fpagecache=5Fpages
>> are horribly badly named, so accurately document them with code comments
>> in case of the misuse of them.
>>
>> Signed-off-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
>> ---
>>  mm/page=5Falloc.c |   23 +++++++++++++++++++----
>>  1 files changed, 19 insertions(+), 4 deletions(-)
>>
>> diff --git a/mm/page=5Falloc.c b/mm/page=5Falloc.c
>> index df2022f..0790716 100644
>> --- a/mm/page=5Falloc.c
>> +++ b/mm/page=5Falloc.c
>> @@ -2785,6 +2785,15 @@ void free=5Fpages=5Fexact(void *virt, size=5Ft si=
ze)
>>  }
>>  EXPORT=5FSYMBOL(free=5Fpages=5Fexact);
>> =20
>> +/**
>> + * nr=5Ffree=5Fzone=5Fpages - get pages that is beyond high watermark
>> + * @offset - The zone index of the highest zone
>=20
> Function parameter format uses a ':', not a '-'.  E.g.,
>=20
>  * @offset: the zone index of the highest zone

Sorry for my mistake. Thanks for your review.

>=20
>=20
>> + *
>> + * The function counts pages which are beyond high watermark within
>> + * all zones at or below a given zone index. For each zone, the
>> + * amount of pages is calculated as:
>> + *     present=5Fpages - high=5Fpages
>> + */
>>  static unsigned int nr=5Ffree=5Fzone=5Fpages(int offset)
>>  {
>>  	struct zoneref *z;
>> @@ -2805,8 +2814,11 @@ static unsigned int nr=5Ffree=5Fzone=5Fpages(int =
offset)
>>  	return sum;
>>  }
>> =20
>> -/*
>> - * Amount of free RAM allocatable within ZONE=5FDMA and ZONE=5FNORMAL
>> +/**
>> + * nr=5Ffree=5Fbuffer=5Fpages - get pages that is beyond high watermark
>> + *
>> + * The function counts pages which are beyond high watermark within
>> + * ZONE=5FDMA and ZONE=5FNORMAL.
>>   */
>>  unsigned int nr=5Ffree=5Fbuffer=5Fpages(void)
>>  {
>> @@ -2814,8 +2826,11 @@ unsigned int nr=5Ffree=5Fbuffer=5Fpages(void)
>>  }
>>  EXPORT=5FSYMBOL=5FGPL(nr=5Ffree=5Fbuffer=5Fpages);
>> =20
>> -/*
>> - * Amount of free RAM allocatable within all zones
>> +/**
>> + * nr=5Ffree=5Fpagecache=5Fpages - get pages that is beyond high waterm=
ark
>> + *
>> + * The function counts pages which are beyond high watermark within
>> + * all zones.
>>   */
>>  unsigned int nr=5Ffree=5Fpagecache=5Fpages(void)
>>  {
>>
>=20
>=20

=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
