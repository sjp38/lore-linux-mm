Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 03CB59000BD
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 23:39:59 -0400 (EDT)
Received: by wyf23 with SMTP id 23so1330794wyf.9
        for <linux-mm@kvack.org>; Tue, 20 Sep 2011 20:39:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110920071408.GB26791@tiehlicka.suse.cz>
References: <1315909531-13419-1-git-send-email-consul.kautuk@gmail.com>
	<20110920071408.GB26791@tiehlicka.suse.cz>
Date: Wed, 21 Sep 2011 09:09:47 +0530
Message-ID: <CAFPAmTQPLPnB8EhZYvcdWFPtmWC+my0M3qoojBsms=0SwQ9XXA@mail.gmail.com>
Subject: Re: [PATCH 1/1] Trivial: Eliminate the ret variable from mm_take_all_locks
From: "kautuk.c @samsung.com" <consul.kautuk@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Shaohua Li <shaohua.li@intel.com>, Jiri Kosina <trivial@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Thanks, Michal.

On Tue, Sep 20, 2011 at 12:44 PM, Michal Hocko <mhocko@suse.cz> wrote:
> On Tue 13-09-11 15:55:31, Kautuk Consul wrote:
>> The ret variable is really not needed in mm_take_all_locks as per
>> the current flow of the mm_take_all_locks function.
>>
>> So, eliminating this return variable.
>>
>> Signed-off-by: Kautuk Consul <consul.kautuk@gmail.com>
>
> The compiled code seems to be very same - compilers are clever enough to
> reorganize the code but anyway the code reads better this way.
>
> Reviewed-by: Michal Hocko <mhocko@suse.cz>
>
>> ---
>> =A0mm/mmap.c | =A0 =A08 +++-----
>> =A01 files changed, 3 insertions(+), 5 deletions(-)
>>
>> diff --git a/mm/mmap.c b/mm/mmap.c
>> index a65efd4..48bc056 100644
>> --- a/mm/mmap.c
>> +++ b/mm/mmap.c
>> @@ -2558,7 +2558,6 @@ int mm_take_all_locks(struct mm_struct *mm)
>> =A0{
>> =A0 =A0 =A0 struct vm_area_struct *vma;
>> =A0 =A0 =A0 struct anon_vma_chain *avc;
>> - =A0 =A0 int ret =3D -EINTR;
>>
>> =A0 =A0 =A0 BUG_ON(down_read_trylock(&mm->mmap_sem));
>>
>> @@ -2579,13 +2578,12 @@ int mm_take_all_locks(struct mm_struct *mm)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vm_lock_anon=
_vma(mm, avc->anon_vma);
>> =A0 =A0 =A0 }
>>
>> - =A0 =A0 ret =3D 0;
>> + =A0 =A0 return 0;
>>
>> =A0out_unlock:
>> - =A0 =A0 if (ret)
>> - =A0 =A0 =A0 =A0 =A0 =A0 mm_drop_all_locks(mm);
>> + =A0 =A0 mm_drop_all_locks(mm);
>>
>> - =A0 =A0 return ret;
>> + =A0 =A0 return -EINTR;
>> =A0}
>>
>> =A0static void vm_unlock_anon_vma(struct anon_vma *anon_vma)
>> --
>> 1.7.6
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org. =A0For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Fight unfair telecom internet charges in Canada: sign http://stopthemete=
r.ca/
>> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>
> --
> Michal Hocko
> SUSE Labs
> SUSE LINUX s.r.o.
> Lihovarska 1060/12
> 190 00 Praha 9
> Czech Republic
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
