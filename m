Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id B1A9D6B057C
	for <linux-mm@kvack.org>; Fri, 18 May 2018 02:10:00 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id f23-v6so4729159wra.20
        for <linux-mm@kvack.org>; Thu, 17 May 2018 23:10:00 -0700 (PDT)
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id h11-v6si6435927edq.57.2018.05.17.23.09.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 May 2018 23:09:58 -0700 (PDT)
Subject: Re: mmotm 2018-05-17-16-26 uploaded (autofs)
From: Ian Kent <raven@themaw.net>
References: <20180517232639.sD6Cz%akpm@linux-foundation.org>
 <19926e1e-6dba-3b9f-fd97-d9eb88bfb7dd@infradead.org>
 <49acf718-da2e-73dc-a3bf-c41d7546576e@themaw.net>
 <9e3dfece-46a0-8ab2-2c7e-3edf956703a8@infradead.org>
 <6441e45b-6216-a20a-5b1d-6f5663d701dd@themaw.net>
Message-ID: <80c2dcf5-b9a9-3d75-7f6f-d0e9c1a11fb9@themaw.net>
Date: Fri, 18 May 2018 14:09:51 +0800
MIME-Version: 1.0
In-Reply-To: <6441e45b-6216-a20a-5b1d-6f5663d701dd@themaw.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>, akpm@linux-foundation.org, broonie@kernel.org, mhocko@suse.cz, sfr@canb.auug.org.au, linux-next@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mm-commits@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>

On 18/05/18 12:38, Ian Kent wrote:
> On 18/05/18 12:23, Randy Dunlap wrote:
>> On 05/17/2018 08:50 PM, Ian Kent wrote:
>>> On 18/05/18 08:21, Randy Dunlap wrote:
>>>> On 05/17/2018 04:26 PM, akpm@linux-foundation.org wrote:
>>>>> The mm-of-the-moment snapshot 2018-05-17-16-26 has been uploaded to
>>>>>
>>>>>    http://www.ozlabs.org/~akpm/mmotm/
>>>>>
>>>>> mmotm-readme.txt says
>>>>>
>>>>> README for mm-of-the-moment:
>>>>>
>>>>> http://www.ozlabs.org/~akpm/mmotm/
>>>>>
>>>>> This is a snapshot of my -mm patch queue.  Uploaded at random hopefully
>>>>> more than once a week.
>>>>>
>>>>> You will need quilt to apply these patches to the latest Linus release (4.x
>>>>> or 4.x-rcY).  The series file is in broken-out.tar.gz and is duplicated in
>>>>> http://ozlabs.org/~akpm/mmotm/series
>>>>>
>>>>> The file broken-out.tar.gz contains two datestamp files: .DATE and
>>>>> .DATE-yyyy-mm-dd-hh-mm-ss.  Both contain the string yyyy-mm-dd-hh-mm-ss,
>>>>> followed by the base kernel version against which this patch series is to
>>>>> be applied.
>>>>>
>>>>> This tree is partially included in linux-next.  To see which patches are
>>>>> included in linux-next, consult the `series' file.  Only the patches
>>>>> within the #NEXT_PATCHES_START/#NEXT_PATCHES_END markers are included in
>>>>> linux-next.
>>>>>
>>>>> A git tree which contains the memory management portion of this tree is
>>>>> maintained at git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git
>>>>> by Michal Hocko.  It contains the patches which are between the
>>>>> "#NEXT_PATCHES_START mm" and "#NEXT_PATCHES_END" markers, from the series
>>>>> file, http://www.ozlabs.org/~akpm/mmotm/series.
>>>>>
>>>>>
>>>>> A full copy of the full kernel tree with the linux-next and mmotm patches
>>>>> already applied is available through git within an hour of the mmotm
>>>>> release.  Individual mmotm releases are tagged.  The master branch always
>>>>> points to the latest release, so it's constantly rebasing.
>>>>
>>>>
>>>> on x86_64: with (randconfig):
>>>> CONFIG_AUTOFS_FS=y
>>>> CONFIG_AUTOFS4_FS=y
>>>
>>> Oh right, I need to make these exclusive.
>>>
>>> I seem to remember trying to do that along the way, can't remember why
>>> I didn't do it in the end.
>>>
>>> Any suggestions about potential problems when doing it?
>>
>> I think that just using "depends on" for each of them will cause kconfig to
>> complain about circular dependencies, so probably using "choice" will be
>> needed.  Or (since this is just temporary?) just say "don't do that."
>>
> 
> No doubt that was what happened, unfortunately I forgot to return to it.
> 
> Right, a conditional with a message should work .... thanks.

It looks like adding:
depends on AUTOFS_FS = n && AUTOFS_FS != m

to autofs4/Kconfig results in autofs4 appearing under the autofs entry
if AUTOFS_FS is not set which should call attention to it.

It also results in AUTOFS4_FS=n for any setting of AUTOFS_FS except n.

Together with some words about it in the AUTOFS4_FS help it should be
enough to raise awareness of the change.

Ian
