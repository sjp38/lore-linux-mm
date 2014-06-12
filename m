Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f49.google.com (mail-qa0-f49.google.com [209.85.216.49])
	by kanga.kvack.org (Postfix) with ESMTP id 033E26B0100
	for <linux-mm@kvack.org>; Thu, 12 Jun 2014 05:44:21 -0400 (EDT)
Received: by mail-qa0-f49.google.com with SMTP id w8so1269019qac.36
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 02:44:21 -0700 (PDT)
Received: from mail-qc0-x234.google.com (mail-qc0-x234.google.com [2607:f8b0:400d:c01::234])
        by mx.google.com with ESMTPS id o9si446672qac.99.2014.06.12.02.44.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 12 Jun 2014 02:44:21 -0700 (PDT)
Received: by mail-qc0-f180.google.com with SMTP id i17so1490184qcy.25
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 02:44:21 -0700 (PDT)
MIME-Version: 1.0
Reply-To: mtk.manpages@gmail.com
In-Reply-To: <20140612094014.BFEA4E00A2@blue.fi.intel.com>
References: <1399552888-11024-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1399552888-11024-2-git-send-email-kirill.shutemov@linux.intel.com>
 <CAHO5Pa31WVrtG+2hU1grbLHiEPjkM_eB4JgSStskX8AvDjQRKA@mail.gmail.com> <20140612094014.BFEA4E00A2@blue.fi.intel.com>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Date: Thu, 12 Jun 2014 11:44:01 +0200
Message-ID: <CAKgNAkhnWwDxr8n7p0m60koRK+a_fhp8yuOssK5_-QEWMJ3qYg@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm: mark remap_file_pages() syscall as deprecated
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Linux API <linux-api@vger.kernel.org>

Hi Kirill,

On Thu, Jun 12, 2014 at 11:40 AM, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
> Michael Kerrisk wrote:
>> Hi Kirill,
>>
>> On Thu, May 8, 2014 at 2:41 PM, Kirill A. Shutemov
>> <kirill.shutemov@linux.intel.com> wrote:
>> > The remap_file_pages() system call is used to create a nonlinear mappi=
ng,
>> > that is, a mapping in which the pages of the file are mapped into a
>> > nonsequential order in memory. The advantage of using remap_file_pages=
()
>> > over using repeated calls to mmap(2) is that the former approach does =
not
>> > require the kernel to create additional VMA (Virtual Memory Area) data
>> > structures.
>> >
>> > Supporting of nonlinear mapping requires significant amount of non-tri=
vial
>> > code in kernel virtual memory subsystem including hot paths. Also to g=
et
>> > nonlinear mapping work kernel need a way to distinguish normal page ta=
ble
>> > entries from entries with file offset (pte_file). Kernel reserves flag=
 in
>> > PTE for this purpose. PTE flags are scarce resource especially on some=
 CPU
>> > architectures. It would be nice to free up the flag for other usage.
>> >
>> > Fortunately, there are not many users of remap_file_pages() in the wil=
d.
>> > It's only known that one enterprise RDBMS implementation uses the sysc=
all
>> > on 32-bit systems to map files bigger than can linearly fit into 32-bi=
t
>> > virtual address space. This use-case is not critical anymore since 64-=
bit
>> > systems are widely available.
>> >
>> > The plan is to deprecate the syscall and replace it with an emulation.
>> > The emulation will create new VMAs instead of nonlinear mappings. It's
>> > going to work slower for rare users of remap_file_pages() but ABI is
>> > preserved.
>> >
>> > One side effect of emulation (apart from performance) is that user can=
 hit
>> > vm.max_map_count limit more easily due to additional VMAs. See comment=
 for
>> > DEFAULT_MAX_MAP_COUNT for more details on the limit.
>>
>> Best to CC linux-api@
>> (https://www.kernel.org/doc/man-pages/linux-api-ml.html) on patches
>> like this, as well as the man-pages maintainer, so that something goes
>> into the man page. I added the following into the man page:
>>
>>        Note:  this  system  call  is (since Linux 3.16) deprecated and
>>        will eventually be replaced by a  slower  in-kernel  emulation.
>>        Those  few  applications  that use this system call should con=E2=
=80=90
>>        sider migrating to alternatives.
>>
>> Okay?
>
> Yep. Looks okay to me.

Thanks for checking.

Cheers,

Michael

--=20
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
