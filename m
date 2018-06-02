Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6DA976B000A
	for <linux-mm@kvack.org>; Sat,  2 Jun 2018 10:55:32 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id q5-v6so260692lff.23
        for <linux-mm@kvack.org>; Sat, 02 Jun 2018 07:55:32 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v18-v6sor10043016ljb.62.2018.06.02.07.55.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 02 Jun 2018 07:55:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180530111602.GB17450@bombadil.infradead.org>
References: <20180529143126.GA19698@jordon-HP-15-Notebook-PC>
 <20180529145055.GA15148@bombadil.infradead.org> <CAFqt6zaxt=wXjvKV0qA+OwU1iUyoBdW2cJSLFqXupVWRpKdqEA@mail.gmail.com>
 <20180529173445.GD15148@bombadil.infradead.org> <CAFqt6zZCX7Ai2w9dV3OvUn=V4Z02H=+FBirjHT3QSU1Fuz+uLQ@mail.gmail.com>
 <20180530111602.GB17450@bombadil.infradead.org>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Sat, 2 Jun 2018 20:25:29 +0530
Message-ID: <CAFqt6zbGyDktxBe0t4W-G8bicA4P8-vDm6fOk+kTod7SHoxvZA@mail.gmail.com>
Subject: Re: [PATCH] mm: Change return type to vm_fault_t
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, zi.yan@cs.rutgers.edu, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, Greg KH <gregkh@linuxfoundation.org>, Mark Rutland <mark.rutland@arm.com>, riel@redhat.com, pasha.tatashin@oracle.com, jschoenh@amazon.de, Kate Stewart <kstewart@linuxfoundation.org>, David Rientjes <rientjes@google.com>, tglx@linutronix.de, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, yang.s@alibaba-inc.com, Minchan Kim <minchan@kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-kernel@vger.kernel.org, Linux-MM <linux-mm@kvack.org>

On Wed, May 30, 2018 at 4:46 PM, Matthew Wilcox <willy@infradead.org> wrote:
> On Wed, May 30, 2018 at 09:10:47AM +0530, Souptick Joarder wrote:
>> On Tue, May 29, 2018 at 11:04 PM, Matthew Wilcox <willy@infradead.org> wrote:
>> > I see:
>> >
>> > mm/gup.c:817:15: warning: invalid assignment: |=
>> > mm/gup.c:817:15:    left side has type int
>> > mm/gup.c:817:15:    right side has type restricted vm_fault_t
>> >
>> > are you building with 'c=2' or 'C=2'?
>>
>> Building with C=2.
>> Do I need to enable any separate FLAG ?
>
> Nope.  Here's what I have:
>
> willy@bobo:~/kernel/souptick$ make C=2 mm/gup.o
>   CHK     include/config/kernel.release
>   CHK     include/generated/uapi/linux/version.h
>   CHK     include/generated/utsrelease.h
>   CHECK   arch/x86/purgatory/purgatory.c
>   CHECK   arch/x86/purgatory/sha256.c
>   CHECK   arch/x86/purgatory/string.c
> arch/x86/purgatory/../boot/string.c:134:6: warning: symbol 'simple_strtol' was not declared. Should it be static?
>   CHK     include/generated/bounds.h
>   CHK     include/generated/timeconst.h
>   CHK     include/generated/asm-offsets.h
>   CALL    scripts/checksyscalls.sh
>   DESCEND  objtool
>   CHECK   scripts/mod/empty.c
>   CHK     scripts/mod/devicetable-offsets.h
>   CHECK   mm/gup.c
> mm/gup.c:817:15: warning: invalid assignment: |=
> mm/gup.c:817:15:    left side has type int
> mm/gup.c:817:15:    right side has type restricted vm_fault_t
>   CC      mm/gup.o
>

Matthew,

Due to some unidentified error still not able to catch this warning
in (X86_64 + sparse) compilation. It is constantly showing below error.

Documents/linux-4.17-rc7$ make C=2 -j4 mm/gup.o

CHK     include/config/kernel.release
  CHK     include/generated/uapi/linux/version.h
  DESCEND  objtool
  CHK     include/generated/utsrelease.h
  CHECK   scripts/mod/empty.c
  CHK     scripts/mod/devicetable-offsets.h
  CHK     include/generated/bounds.h
  CHK     include/generated/timeconst.h
  CHK     include/generated/asm-offsets.h
  CALL    scripts/checksyscalls.sh
  CHECK   mm/gup.c
mm/gup.c:394:17: error: undefined identifier '__COUNTER__'
mm/gup.c:439:9: error: undefined identifier '__COUNTER__'
mm/gup.c:441:9: error: undefined identifier '__COUNTER__'
mm/gup.c:443:9: error: undefined identifier '__COUNTER__'
mm/gup.c:508:17: error: undefined identifier '__COUNTER__'
mm/gup.c:716:25: error: undefined identifier '__COUNTER__'
mm/gup.c:826:17: error: undefined identifier '__COUNTER__'
mm/gup.c:863:17: error: undefined identifier '__COUNTER__'
mm/gup.c:865:17: error: undefined identifier '__COUNTER__'
mm/gup.c:882:25: error: undefined identifier '__COUNTER__'
mm/gup.c:883:25: error: undefined identifier '__COUNTER__'
mm/gup.c:920:25: error: undefined identifier '__COUNTER__'
./include/linux/hugetlb.h:239:9: error: undefined identifier '__COUNTER__'

But able to capture it in (powerpc + sparse) compilation.
I will fix it in v2.

/Documents/linux-4.17-rc7$ make C=2 ARCH=powerpc
CROSS_COMPILE=powerpc-linux-gnu- mm/gup.o

  CHK     include/config/kernel.release
  CHK     include/generated/uapi/linux/version.h
  CHK     include/generated/utsrelease.h
  CHK     include/generated/bounds.h
  CHK     include/generated/timeconst.h
  CHK     include/generated/asm-offsets.h
  CALL    scripts/checksyscalls.sh
  CHECK   scripts/mod/empty.c
  CHK     scripts/mod/devicetable-offsets.h
  CHECK   mm/gup.c
./arch/powerpc/include/asm/book3s/64/pgtable.h:669:24: warning:
restricted __be64 degrades to integer
mm/gup.c:820:15: warning: incorrect type in assignment (different base types)
mm/gup.c:820:15:    expected int [signed] major
mm/gup.c:820:15:    got restricted vm_fault_t
mm/gup.c:1247:24: warning: expression using sizeof bool
mm/gup.c:1247:24: warning: expression using sizeof(void)
mm/gup.c:1247:24: warning: expression using sizeof(void)
./arch/powerpc/include/asm/book3s/64/pgtable.h:667:20: warning:
incorrect type in initializer (different base types)
./arch/powerpc/include/asm/book3s/64/pgtable.h:667:20:    expected
unsigned long long [unsigned] [usertype] mask
./arch/powerpc/include/asm/book3s/64/pgtable.h:667:20:    got
restricted __be64 [usertype] <noident>
mm/gup.c:1735:6: warning: symbol 'gup_fast_permitted' was not
declared. Should it be static?
  CC      mm/gup.o


Also Sparse is throwing below warning ->

/Documents/linux-4.17-rc7$ make C=2 ARCH=powerpc
CROSS_COMPILE=powerpc-linux-gnu- mm/hugetlb.o

 CHK     include/config/kernel.release
  CHK     include/generated/uapi/linux/version.h
  CHK     include/generated/utsrelease.h
  CHK     include/generated/bounds.h
  CHK     include/generated/timeconst.h
  CHK     include/generated/asm-offsets.h
  CALL    scripts/checksyscalls.sh
  CHECK   scripts/mod/empty.c
  CHK     scripts/mod/devicetable-offsets.h
  CHECK   mm/hugetlb.c
mm/hugetlb.c:3778:33: warning: restricted vm_fault_t degrades to integer
mm/hugetlb.c:3777:31: warning: restricted vm_fault_t degrades to integer
mm/hugetlb.c:3777:29: warning: incorrect type in assignment (different
base types)
mm/hugetlb.c:3777:29:    expected restricted vm_fault_t [assigned]
[usertype] ret
mm/hugetlb.c:3777:29:    got unsigned int
mm/hugetlb.c:3895:33: warning: restricted vm_fault_t degrades to integer
mm/hugetlb.c:3894:32: warning: restricted vm_fault_t degrades to integer
mm/hugetlb.c:3894:56: warning: incorrect type in return expression
(different base types)
mm/hugetlb.c:3894:56:    expected restricted vm_fault_t
mm/hugetlb.c:3894:56:    got unsigned int

Which is fixed by ->

"#define VM_FAULT_SET_HINDEX(x) ((__force vm_fault_t)((x) << 16))"

in final vm_fault_t patch.

Does it looks good ?
