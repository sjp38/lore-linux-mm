Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 90F9B6B0388
	for <linux-mm@kvack.org>; Fri, 17 Mar 2017 18:06:15 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id 81so132212582pgh.3
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 15:06:15 -0700 (PDT)
Received: from cmccmta3.chinamobile.com (cmccmta3.chinamobile.com. [221.176.66.81])
        by mx.google.com with ESMTP id y76si6985776pfi.244.2017.03.17.15.06.13
        for <linux-mm@kvack.org>;
        Fri, 17 Mar 2017 15:06:14 -0700 (PDT)
In-Reply-To: <2dd405f8-9f5b-405d-e744-9ee8bac77686@redhat.com>
References: <1488962743-17028-1-git-send-email-lixiubo@cmss.chinamobile.com><1488962743-17028-3-git-send-email-lixiubo@cmss.chinamobile.com><3b1ce412-6072-fda1-3002-220cf8fbf34f@redhat.com><ddd797ea-43f0-b863-64e4-1e758f41dafe@cmss.chinamobile.com><f4c4e83a-d6b1-ed57-7a54-4277722e5a46@cmss.chinamobile.com> <2dd405f8-9f5b-405d-e744-9ee8bac77686@redhat.com>
MIME-Version: 1.0
Content-Type: multipart/alternative; boundary="----DTKAJ5MA9N3GK5FOKD5BA28PNDC3L3"
Subject: Re:  [PATCHv2 2/5] target/user: Add global data block pool support
From: =?UTF-8?B?5p2O56eA5rOi?= <lixiubo@cmss.chinamobile.com>
Date: Sat, 18 Mar 2017 06:06:11 +0800
Message-ID: <13903058-78b8-4737-9eef-849ee7bca307@email.android.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: AndyGrover <agrover@redhat.com>, nab@linux-iscsi.org, mchristi@redhat.com
Cc: shli@kernel.org, sheng@yasker.org, linux-scsi@vger.kernel.org, target-devel@vger.kernel.org, namei.unix@gmail.com, linux-mm@kvack.org

------DTKAJ5MA9N3GK5FOKD5BA28PNDC3L3
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: quoted-printable



AndyGrover <agrover@redhat=2Ecom>=E5=86=99=E5=88=B0=EF=BC=9A
>On 03/17/20=
17 01:04 AM, Xiubo Li wrote:
>> [=2E=2E=2E]
>>> These days what I have gott=
en is that the unmap_mapping_range()
>could
>>> be used=2E
>>> At the same =
time I have deep into the mm code and fixed the double
>>> usage of
>>> the=
 data blocks and possible page fault call trace bugs mentioned
>above=2E
>>=
>
>>> Following is the V3 patch=2E I have test this using 4 targets & fio
>=
for
>>> about 2 days, so
>>> far so good=2E
>>>
>>> I'm still testing this =
using more complex test case=2E
>>>
>> I have test it the whole day today:
=
>> - using 4 targets
>> - setting TCMU_GLOBAL_MAX_BLOCKS =3D [512 1K 1M 1G =
2G]
>> - each target here needs more than 450 blocks when running
>> - fio:=
 -iodepth [1 2 4 8 16] -thread -rw=3D[read write] -bs=3D[1K 2K 3K
>5K
>> 7K=
 16K 64K 1M] -size=3D20G -numjobs=3D10 -runtime=3D1000  =2E=2E=2E
>
>Hi Xiu=
bo,
>
>V3 is sounding very good=2E I look forward to reviewing it after it =
is
>posted=2E
>

Yes, I will post it later after more test and checking=2E
=

Thanks,

BRs
Xiubo


>Thanks -- Regards -- Andy

------DTKAJ5MA9N3GK5FOKD5BA28PNDC3L3
Content-Type: text/html;
 charset=utf-8
Content-Transfer-Encoding: quoted-printable

<br><br>AndyGrover <agrover@redhat=2Ecom>=E5=86=99=E5=88=B0=EF=BC=9A<BR>>On=
 03/17/2017 01:04 AM, Xiubo Li wrote:<BR>>> [=2E=2E=2E]<BR>>>> These days w=
hat I have gotten is that the unmap_mapping_range()<BR>>could<BR>>>> be use=
d=2E<BR>>>> At the same time I have deep into the mm code and fixed the dou=
ble<BR>>>> usage of<BR>>>> the data blocks and possible page fault call tra=
ce bugs mentioned<BR>>above=2E<BR>>>><BR>>>> Following is the V3 patch=2E I=
 have test this using 4 targets & fio<BR>>for<BR>>>> about 2 days, so<BR>>>=
> far so good=2E<BR>>>><BR>>>> I'm still testing this using more complex te=
st case=2E<BR>>>><BR>>> I have test it the whole day today:<BR>>> - using 4=
 targets<BR>>> - setting TCMU_GLOBAL_MAX_BLOCKS =3D [512 1K 1M 1G 2G]<BR>>>=
 - each target here needs more than 450 blocks when running<BR>>> - fio: -i=
odepth [1 2 4 8 16] -thread -rw=3D[read write] -bs=3D[1K 2K 3K<BR>>5K<BR>>>=
 7K 16K 64K 1M] -size=3D20G -numjobs=3D10 -runtime=3D1000  =2E=2E=2E<BR>><B=
R>>Hi Xiubo,<BR>><BR>>V3 is sounding very good=2E I look forward to reviewi=
ng it after it is<BR>>posted=2E<BR>><BR><BR>Yes, I will post it later after=
 more test and checking=2E<BR><BR>Thanks,<BR><BR>BRs<BR>Xiubo<BR><BR><BR>>T=
hanks -- Regards -- Andy<BR>
------DTKAJ5MA9N3GK5FOKD5BA28PNDC3L3--



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
