Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7CDCB6B0005
	for <linux-mm@kvack.org>; Fri,  1 Jul 2016 12:12:00 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id l184so84768954lfl.3
        for <linux-mm@kvack.org>; Fri, 01 Jul 2016 09:12:00 -0700 (PDT)
Received: from mail-lf0-x234.google.com (mail-lf0-x234.google.com. [2a00:1450:4010:c07::234])
        by mx.google.com with ESMTPS id m188si5016414lfd.234.2016.07.01.09.11.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Jul 2016 09:11:59 -0700 (PDT)
Received: by mail-lf0-x234.google.com with SMTP id l188so80351202lfe.2
        for <linux-mm@kvack.org>; Fri, 01 Jul 2016 09:11:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5776945F.5080303@virtuozzo.com>
References: <CACT4Y+Y9rhgTCuFbg5f4KHzR-_p4-mf4sVn4zoa-3hnY6iEmMQ@mail.gmail.com>
 <5776945F.5080303@virtuozzo.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Fri, 1 Jul 2016 18:11:39 +0200
Message-ID: <CACT4Y+ZVUGfNr9Urzf7roy+t9EBa9rTWvmDeAp_4hopaPbBGpQ@mail.gmail.com>
Subject: Re: mm: BUG in page_move_anon_rmap
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Hugh Dickins <hughd@google.com>, LKML <linux-kernel@vger.kernel.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Greg Thelen <gthelen@google.com>, Suleiman Souhlal <suleiman@google.com>, syzkaller <syzkaller@googlegroups.com>, Kostya Serebryany <kcc@google.com>, Alexander Potapenko <glider@google.com>, Sasha Levin <sasha.levin@oracle.com>

On Fri, Jul 1, 2016 at 6:03 PM, Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:
>
>
> On 07/01/2016 06:31 PM, Dmitry Vyukov wrote:
>> Hello,
>>
>> I am getting the following crashes while running syzkaller fuzzer on
>> 00bf377d19ad3d80cbc7a036521279a86e397bfb (Jun 29). So far I did not
>> manage to reproduce it outside of fuzzer, but fuzzer hits it once per
>> hour or so.
>>
>> flags: 0xfffe0000044079(locked|uptodate|dirty|lru|active|head|swapbacked)
>
> This report is incomplete. It lacks one line ahead with page address, mapcount, index, etc.
>
>> page dumped because: VM_BUG_ON_PAGE(page->index !=
>> linear_page_index(vma, address))
>> page->mem_cgroup:ffff88003e829be0
>> ------------[ cut here ]------------
>> kernel BUG at mm/rmap.c:1103!
>> invalid opcode: 0000 [#2] SMP DEBUG_PAGEALLOC KASAN
>> Modules linked in:
>> CPU: 0 PID: 7043 Comm: syz-fuzzer Tainted: G      D         4.7.0-rc5+ #22
>
> So the kernel is already tainted. Can you show us the first oops message?

Here are 3 reports on non tainted kernels:
https://gist.githubusercontent.com/dvyukov/b70bc7ce5d1b69d36c00949ea7dec8ae/raw/0551cd816bf9d7c13ef8249c72dd32b976626086/gistfile1.txt
https://gist.githubusercontent.com/dvyukov/461bd8b185bcd374ccb9ace852b89441/raw/4f77600467717e776ec1c10d136bdf23ddbab3e1/gistfile1.txt
https://gist.githubusercontent.com/dvyukov/0078ec38b3e320173610cf6a0c2e107b/raw/488384222fe5e25d1d425ca29782e0b3e9273ffa/gistfile1.txt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
