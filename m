Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id CF99C6B007B
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 01:23:38 -0400 (EDT)
Received: from hpaq6.eem.corp.google.com (hpaq6.eem.corp.google.com [172.25.149.6])
	by smtp-out.google.com with ESMTP id o8F5NXXm022294
	for <linux-mm@kvack.org>; Tue, 14 Sep 2010 22:23:33 -0700
Received: from pxi5 (pxi5.prod.google.com [10.243.27.5])
	by hpaq6.eem.corp.google.com with ESMTP id o8F5NV8L012476
	for <linux-mm@kvack.org>; Tue, 14 Sep 2010 22:23:32 -0700
Received: by pxi5 with SMTP id 5so3081053pxi.14
        for <linux-mm@kvack.org>; Tue, 14 Sep 2010 22:23:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <AANLkTinBs-fK4=fr+pc7aK0X+SBgkXDCB9n1aXsg=jyD@mail.gmail.com>
References: <1284357493-20078-1-git-send-email-mrubin@google.com>
 <1284357493-20078-4-git-send-email-mrubin@google.com> <20100913142017.2a426365.akpm@linux-foundation.org>
 <AANLkTinBs-fK4=fr+pc7aK0X+SBgkXDCB9n1aXsg=jyD@mail.gmail.com>
From: Michael Rubin <mrubin@google.com>
Date: Tue, 14 Sep 2010 22:23:11 -0700
Message-ID: <AANLkTik0xT5YBfKRPY6F8m4-iLc47H_tuqHAN6nNFdXk@mail.gmail.com>
Subject: Re: [PATCH 3/5] writeback: nr_dirtied and nr_written in /proc/vmstat
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com, jack@suse.cz, riel@redhat.com, david@fromorbit.com, kosaki.motohiro@jp.fujitsu.com, npiggin@kernel.dk, hch@lst.de, axboe@kernel.dk
List-ID: <linux-mm.kvack.org>

I know it's been applied but in case you want minor nits fixed. I am
sending one more update.

mrubin

On Mon, Sep 13, 2010 at 3:17 PM, Michael Rubin <mrubin@google.com> wrote:
> On Mon, Sep 13, 2010 at 2:20 PM, Andrew Morton
> <akpm@linux-foundation.org> wrote:
>> On Sun, 12 Sep 2010 22:58:11 -0700
>> Michael Rubin <mrubin@google.com> wrote:
>>
>>> To help developers and applications gain visibility into writeback
>>> behaviour adding two entries to vm_stat_items and /proc/vmstat. This
>>> will allow us to track the "written" and "dirtied" counts.
>>>
>>> =A0 =A0# grep nr_dirtied /proc/vmstat
>>> =A0 =A0nr_dirtied 3747
>>> =A0 =A0# grep nr_written /proc/vmstat
>>> =A0 =A0nr_written 3618
>>>
>>> Signed-off-by: Michael Rubin <mrubin@google.com>
>>> Reviewed-by: Wu Fengguang <fengguang.wu@intel.com>
>>> ---
>>> =A0include/linux/mmzone.h | =A0 =A02 ++
>>> =A0mm/page-writeback.c =A0 =A0| =A0 =A02 ++
>>> =A0mm/vmstat.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A03 +++
>>> =A03 files changed, 7 insertions(+), 0 deletions(-)
>>>
>>> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
>>> index 6e6e626..d0d7454 100644
>>> --- a/include/linux/mmzone.h
>>> +++ b/include/linux/mmzone.h
>>> @@ -104,6 +104,8 @@ enum zone_stat_item {
>>> =A0 =A0 =A0 NR_ISOLATED_ANON, =A0 =A0 =A0 /* Temporary isolated pages f=
rom anon lru */
>>> =A0 =A0 =A0 NR_ISOLATED_FILE, =A0 =A0 =A0 /* Temporary isolated pages f=
rom file lru */
>>> =A0 =A0 =A0 NR_SHMEM, =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* shmem pages (inclu=
ded tmpfs/GEM pages) */
>>> + =A0 =A0 NR_FILE_DIRTIED, =A0 =A0 =A0 =A0/* accumulated dirty pages */
>>> + =A0 =A0 NR_WRITTEN, =A0 =A0 =A0 =A0 =A0 =A0 /* accumulated written pa=
ges */
>>
>> I think we can make those comments less ambiguous>
>>
>> --- a/include/linux/mmzone.h
>> +++ a/include/linux/mmzone.h
>> @@ -104,8 +104,8 @@ enum zone_stat_item {
>> =A0 =A0 =A0 =A0NR_ISOLATED_ANON, =A0 =A0 =A0 /* Temporary isolated pages=
 from anon lru */
>> =A0 =A0 =A0 =A0NR_ISOLATED_FILE, =A0 =A0 =A0 /* Temporary isolated pages=
 from file lru */
>> =A0 =A0 =A0 =A0NR_SHMEM, =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* shmem pages (inc=
luded tmpfs/GEM pages) */
>> - =A0 =A0 =A0 NR_FILE_DIRTIED, =A0 =A0 =A0 =A0/* accumulated dirty pages=
 */
>> - =A0 =A0 =A0 NR_WRITTEN, =A0 =A0 =A0 =A0 =A0 =A0 /* accumulated written=
 pages */
>> + =A0 =A0 =A0 NR_FILE_DIRTIED, =A0 =A0 =A0 =A0/* page dirtyings since bo=
otup */
>> + =A0 =A0 =A0 NR_WRITTEN, =A0 =A0 =A0 =A0 =A0 =A0 /* page writings since=
 bootup */
>
> Got it. Will fix.
>
>> The mismatch between "NR_FILE_DIRTIED" and "nr_dirtied" is a bit, umm,
>> dirty. =A0I can kinda see the logic in the naming but still..
>
> Got it will fix.
>
> mrubin
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
