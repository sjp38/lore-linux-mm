Received: by wa-out-1112.google.com with SMTP id m33so476748wag
        for <linux-mm@kvack.org>; Wed, 06 Jun 2007 20:27:02 -0700 (PDT)
Message-ID: <787b0d920706062027s5a8fd35q752f8da5d446afc@mail.gmail.com>
Date: Wed, 6 Jun 2007 23:27:01 -0400
From: "Albert Cahalan" <acahalan@gmail.com>
Subject: Re: [RFC][PATCH] /proc/pid/maps doesn't match "ipcs -m" shmid
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, ebiederm@xmission.com, pbadari@us.ibm.com, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Eric W. Biederman writes:
> Badari Pulavarty <pbadari@us.ibm.com> writes:

>> Your recent cleanup to shm code, namely
>>
>> [PATCH] shm: make sysv ipc shared memory use stacked files
>>
>> took away one of the debugging feature for shm segments.
>> Originally, shmid were forced to be the inode numbers and
>> they show up in /proc/pid/maps for the process which mapped
>> this shared memory segments (vma listing). That way, its easy
>> to find out who all mapped this shared memory segment. Your
>> patchset, took away the inode# setting. So, we can't easily
>> match the shmem segments to /proc/pid/maps easily. (It was
>> really useful in tracking down a customer problem recently).
>> Is this done deliberately ? Anything wrong in setting this back ?
>
> Theoretically it makes the stacked file concept more brittle,
> because it means the lower layers can't care about their inode
> number.
>
> We do need something to tie these things together.
>
> So I suspect what makes most sense is to simply rename the
> dentry SYSVID<segmentid>

Please stop breaking things in /proc. The pmap command relys
on the old behavior. It's time to revert. Put back the segment ID
where it belongs, and leave the key where it belongs too.

Containers are NOT worth breaking our ABIs left and right.
We don't need to leap off that bridge just because Solaris did,
unless you can explain why complexity and bloat are desirable.
We already have SE Linux, chroot, KVM, and several more!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
