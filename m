Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id BC7026B0253
	for <linux-mm@kvack.org>; Wed, 20 Dec 2017 03:45:09 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id a22so5052102wme.0
        for <linux-mm@kvack.org>; Wed, 20 Dec 2017 00:45:09 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id e24sor9647254edc.17.2017.12.20.00.45.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Dec 2017 00:45:08 -0800 (PST)
MIME-Version: 1.0
Reply-To: mtk.manpages@gmail.com
In-Reply-To: <f8745470-b4fb-97ef-d6ab-40b437be181c@colorfullife.com>
References: <20171219094848.GE2787@dhcp22.suse.cz> <f8745470-b4fb-97ef-d6ab-40b437be181c@colorfullife.com>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Date: Wed, 20 Dec 2017 09:44:47 +0100
Message-ID: <CAKgNAkhkkx3znnfUN3rsY+SL7k5R+W0ui8__y1-WMLG=PFrCuQ@mail.gmail.com>
Subject: Re: shmctl(SHM_STAT) vs. /proc/sysvipc/shm permissions discrepancies
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Dr. Manfred Spraul" <manfred@colorfullife.com>
Cc: Michal Hocko <mhocko@kernel.org>, Linux API <linux-api@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Kees Cook <keescook@chromium.org>, Linus Torvalds <torvalds@linux-foundation.org>, Mike Waychison <mikew@google.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Hi Manfred,

On 20 December 2017 at 09:32, Dr. Manfred Spraul
<manfred@colorfullife.com> wrote:
> Hi Michal,
>
> On 12/19/2017 10:48 AM, Michal Hocko wrote:
>>
>> Hi,
>> we have been contacted by our partner about the following permission
>> discrepancy
>> 1. Create a shared memory segment with permissions 600 with user A using
>>     shmget(key, 1024, 0600 | IPC_CREAT)
>> 2. ipcs -m should return an output as follows:
>>
>> ------ Shared Memory Segments --------
>> key        shmid      owner      perms      bytes      nattch     status
>> 0x58b74326 759562241  A          600        1024       0
>>
>> 3. Try to read the metadata with shmctl(0, SHM_STAT,...) as user B.
>> 4. shmctl will return -EACCES
>>
>> The supper set information provided by shmctl can be retrieved by
>> reading /proc/sysvipc/shm which does not require read permissions
>> because it is 444.
>>
>> It seems that the discrepancy is there since ae7817745eef ("[PATCH] ipc:
>> add generic struct ipc_ids seq_file iteration") when the proc interface
>> has been introduced. The changelog is really modest on information or
>> intention but I suspect this just got overlooked during review. SHM_STAT
>> has always been about read permission and it is explicitly documented
>> that way.
>
> Are you sure that this patch changed the behavior?
> The proc interface is much older.

Yes, I think that's correct. The /proc/sysvipc interface appeared in
2.3.x, and AFAIK the behavior was already different from *_STAT back
then.

Cheers,

Michael


-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
