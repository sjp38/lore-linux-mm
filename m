Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id B62C86B0038
	for <linux-mm@kvack.org>; Wed, 20 Dec 2017 03:32:05 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id s41so12538078wrc.22
        for <linux-mm@kvack.org>; Wed, 20 Dec 2017 00:32:05 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id c93sor9528392edd.26.2017.12.20.00.32.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Dec 2017 00:32:04 -0800 (PST)
Subject: Re: shmctl(SHM_STAT) vs. /proc/sysvipc/shm permissions discrepancies
References: <20171219094848.GE2787@dhcp22.suse.cz>
From: "Dr. Manfred Spraul" <manfred@colorfullife.com>
Message-ID: <f8745470-b4fb-97ef-d6ab-40b437be181c@colorfullife.com>
Date: Wed, 20 Dec 2017 09:32:01 +0100
MIME-Version: 1.0
In-Reply-To: <20171219094848.GE2787@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-api@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Kees Cook <keescook@chromium.org>, Linus Torvalds <torvalds@linux-foundation.org>, Mike Waychison <mikew@google.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

Hi Michal,

On 12/19/2017 10:48 AM, Michal Hocko wrote:
> Hi,
> we have been contacted by our partner about the following permission
> discrepancy
> 1. Create a shared memory segment with permissions 600 with user A using
>     shmget(key, 1024, 0600 | IPC_CREAT)
> 2. ipcs -m should return an output as follows:
>
> ------ Shared Memory Segments --------
> key        shmid      owner      perms      bytes      nattch     status
> 0x58b74326 759562241  A          600        1024       0
>
> 3. Try to read the metadata with shmctl(0, SHM_STAT,...) as user B.
> 4. shmctl will return -EACCES
>
> The supper set information provided by shmctl can be retrieved by
> reading /proc/sysvipc/shm which does not require read permissions
> because it is 444.
>
> It seems that the discrepancy is there since ae7817745eef ("[PATCH] ipc:
> add generic struct ipc_ids seq_file iteration") when the proc interface
> has been introduced. The changelog is really modest on information or
> intention but I suspect this just got overlooked during review. SHM_STAT
> has always been about read permission and it is explicitly documented
> that way.
Are you sure that this patch changed the behavior?
The proc interface is much older.

--
 A A A  Manfred

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
