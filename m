Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 558016B0038
	for <linux-mm@kvack.org>; Fri, 22 Dec 2017 13:30:11 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id l99so11122657wrc.18
        for <linux-mm@kvack.org>; Fri, 22 Dec 2017 10:30:11 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id i8sor10386410wre.3.2017.12.22.10.30.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 22 Dec 2017 10:30:09 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <843a6fd0-b8a3-7146-fe48-f9e81977f567@oracle.com>
References: <20171107122800.25517-1-marcandre.lureau@redhat.com>
 <aca9951c-7b8a-7884-5b31-c505e4e35d8a@oracle.com> <CAJ+F1CJCbmUHSMfKou_LP3eMq+p-b7S9vbe1Vv=JsGMFr7bk_w@mail.gmail.com>
 <20171220151051.GV4831@dhcp22.suse.cz> <20171220162653.4beeadd43629ccb8a5901aea@linux-foundation.org>
 <843a6fd0-b8a3-7146-fe48-f9e81977f567@oracle.com>
From: =?UTF-8?B?TWFyYy1BbmRyw6kgTHVyZWF1?= <marcandre.lureau@gmail.com>
Date: Fri, 22 Dec 2017 19:30:08 +0100
Message-ID: <CAJ+F1CLpYCY3XFi7uGOvuqUocR1z-L+UeubQefHJSD0ymZ97Ng@mail.gmail.com>
Subject: Re: [PATCH v3 0/9] memfd: add sealing to hugetlb-backed memory
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, open list <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, nyc@holomorphy.com, David Herrmann <dh.herrmann@gmail.com>

Hi Mike

On Thu, Dec 21, 2017 at 1:40 AM, Mike Kravetz <mike.kravetz@oracle.com> wro=
te:
> On 12/20/2017 04:26 PM, Andrew Morton wrote:
>> On Wed, 20 Dec 2017 16:10:51 +0100 Michal Hocko <mhocko@kernel.org> wrot=
e:
>>
>>> On Wed 20-12-17 15:15:50, Marc-Andr=C3=A9 Lureau wrote:
>>>> Hi
>>>>
>>>> On Wed, Nov 15, 2017 at 4:13 AM, Mike Kravetz <mike.kravetz@oracle.com=
> wrote:
>>>>> +Cc: Andrew, Michal, David
>>>>>
>>>>> Are there any other comments on this patch series from Marc-Andr=C3=
=A9?  Is anything
>>>>> else needed to move forward?
>>>>>
>>>>> I have reviewed the patches in the series.  David Herrmann (the origi=
nal
>>>>> memfd_create/file sealing author) has also taken a look at the patche=
s.
>>>>>
>>>>> One outstanding issue is sorting out the config option dependencies. =
 Although,
>>>>> IMO this is not a strict requirement for this series.  I have address=
ed this
>>>>> issue in a follow on series:
>>>>> http://lkml.kernel.org/r/20171109014109.21077-1-mike.kravetz@oracle.c=
om
>>>>
>>>> Are we good for the next merge window? Is Hugh Dickins the maintainer
>>>> with the final word, and doing the pull request? (sorry, I am not very
>>>> familiar with kernel development)
>>>
>>> Andrew will pick it up, I assume. I will try to get and review this but
>>> there is way too much going on before holiday.
>>
>> Yup, things are quiet at present.
>>
>> I'll suck these up for a bit of testing - please let me know if you'd
>> prefer them to be held back for a cycle (ie: for 4.17-rc1)
>
> Thanks Andrew,
>
> As mentioned above there is one issue related to this series that we may
> want to address.  It is described in the series at:
> http://lkml.kernel.org/r/20171109014109.21077-1-mike.kravetz@oracle.com
>
> I did not get many comments on this series/issue.  If we want to do
> something like this, now might be a good time.

I am not the best person to say, but I think that series makes a lot
of sense (and looks good to me). However, I don't think we need to
wait for it to get the sealing support added (furthermore, your rfc
series is on top).

Thanks!


--=20
Marc-Andr=C3=A9 Lureau

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
