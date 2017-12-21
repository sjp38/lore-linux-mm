Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id BF4DF6B0069
	for <linux-mm@kvack.org>; Wed, 20 Dec 2017 19:40:23 -0500 (EST)
Received: by mail-vk0-f72.google.com with SMTP id p197so11215823vkf.14
        for <linux-mm@kvack.org>; Wed, 20 Dec 2017 16:40:23 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id 9si4647383uas.142.2017.12.20.16.40.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Dec 2017 16:40:22 -0800 (PST)
Subject: Re: [PATCH v3 0/9] memfd: add sealing to hugetlb-backed memory
References: <20171107122800.25517-1-marcandre.lureau@redhat.com>
 <aca9951c-7b8a-7884-5b31-c505e4e35d8a@oracle.com>
 <CAJ+F1CJCbmUHSMfKou_LP3eMq+p-b7S9vbe1Vv=JsGMFr7bk_w@mail.gmail.com>
 <20171220151051.GV4831@dhcp22.suse.cz>
 <20171220162653.4beeadd43629ccb8a5901aea@linux-foundation.org>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <843a6fd0-b8a3-7146-fe48-f9e81977f567@oracle.com>
Date: Wed, 20 Dec 2017 16:40:13 -0800
MIME-Version: 1.0
In-Reply-To: <20171220162653.4beeadd43629ccb8a5901aea@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>
Cc: =?UTF-8?Q?Marc-Andr=c3=a9_Lureau?= <marcandre.lureau@gmail.com>, linux-mm@kvack.org, open list <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, nyc@holomorphy.com, David Herrmann <dh.herrmann@gmail.com>

On 12/20/2017 04:26 PM, Andrew Morton wrote:
> On Wed, 20 Dec 2017 16:10:51 +0100 Michal Hocko <mhocko@kernel.org> wrote:
> 
>> On Wed 20-12-17 15:15:50, Marc-AndrA(C) Lureau wrote:
>>> Hi
>>>
>>> On Wed, Nov 15, 2017 at 4:13 AM, Mike Kravetz <mike.kravetz@oracle.com> wrote:
>>>> +Cc: Andrew, Michal, David
>>>>
>>>> Are there any other comments on this patch series from Marc-AndrA(C)?  Is anything
>>>> else needed to move forward?
>>>>
>>>> I have reviewed the patches in the series.  David Herrmann (the original
>>>> memfd_create/file sealing author) has also taken a look at the patches.
>>>>
>>>> One outstanding issue is sorting out the config option dependencies.  Although,
>>>> IMO this is not a strict requirement for this series.  I have addressed this
>>>> issue in a follow on series:
>>>> http://lkml.kernel.org/r/20171109014109.21077-1-mike.kravetz@oracle.com
>>>
>>> Are we good for the next merge window? Is Hugh Dickins the maintainer
>>> with the final word, and doing the pull request? (sorry, I am not very
>>> familiar with kernel development)
>>
>> Andrew will pick it up, I assume. I will try to get and review this but
>> there is way too much going on before holiday.
> 
> Yup, things are quiet at present.
> 
> I'll suck these up for a bit of testing - please let me know if you'd
> prefer them to be held back for a cycle (ie: for 4.17-rc1)

Thanks Andrew,

As mentioned above there is one issue related to this series that we may
want to address.  It is described in the series at:
http://lkml.kernel.org/r/20171109014109.21077-1-mike.kravetz@oracle.com

I did not get many comments on this series/issue.  If we want to do
something like this, now might be a good time.
-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
