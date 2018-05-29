Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4CBE56B0007
	for <linux-mm@kvack.org>; Tue, 29 May 2018 11:55:08 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id a7-v6so13241476wrq.13
        for <linux-mm@kvack.org>; Tue, 29 May 2018 08:55:08 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j75-v6sor1908737ljb.2.2018.05.29.08.55.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 29 May 2018 08:55:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180529145055.GA15148@bombadil.infradead.org>
References: <20180529143126.GA19698@jordon-HP-15-Notebook-PC> <20180529145055.GA15148@bombadil.infradead.org>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Tue, 29 May 2018 21:25:05 +0530
Message-ID: <CAFqt6zaxt=wXjvKV0qA+OwU1iUyoBdW2cJSLFqXupVWRpKdqEA@mail.gmail.com>
Subject: Re: [PATCH] mm: Change return type to vm_fault_t
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, zi.yan@cs.rutgers.edu, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, Greg KH <gregkh@linuxfoundation.org>, Mark Rutland <mark.rutland@arm.com>, riel@redhat.com, pasha.tatashin@oracle.com, jschoenh@amazon.de, Kate Stewart <kstewart@linuxfoundation.org>, David Rientjes <rientjes@google.com>, tglx@linutronix.de, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, yang.s@alibaba-inc.com, Minchan Kim <minchan@kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-kernel@vger.kernel.org, Linux-MM <linux-mm@kvack.org>

On Tue, May 29, 2018 at 8:20 PM, Matthew Wilcox <willy@infradead.org> wrote:
> On Tue, May 29, 2018 at 08:01:26PM +0530, Souptick Joarder wrote:
>> Use new return type vm_fault_t for fault handler. For
>> now, this is just documenting that the function returns
>> a VM_FAULT value rather than an errno. Once all instances
>> are converted, vm_fault_t will become a distinct type.
>
> I don't believe you've checked this with sparse.
>
>> @@ -802,7 +802,8 @@ int fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
>>                    bool *unlocked)
>>  {
>>       struct vm_area_struct *vma;
>> -     int ret, major = 0;
>> +     int major = 0;
>> +     vm_fault_t ret;
>>
>>       if (unlocked)
>>               fault_flags |= FAULT_FLAG_ALLOW_RETRY;
>
> ...
>         major |= ret & VM_FAULT_MAJOR;
>
> That should be throwing a warning.

Sorry, but I verified again and didn't see similar warnings.

steps followed -

apply the patch
make c=2 -j4 ( build for x86_64)
looking for warnings in files because of this patch.

The only error I am seeing "error: undefined identifier '__COUNTER__' "
which is pointing to BUG(). There are few warnings but those are not
related to this patch.

In my test tree the final patch to create new vm_fault_t type is
already applied.

Do you want me to verify in some other way ?
