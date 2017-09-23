Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0E7FD6B0038
	for <linux-mm@kvack.org>; Sat, 23 Sep 2017 02:01:13 -0400 (EDT)
Received: by mail-ua0-f200.google.com with SMTP id 72so2474422uas.7
        for <linux-mm@kvack.org>; Fri, 22 Sep 2017 23:01:13 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i36sor731760uah.252.2017.09.22.23.01.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 22 Sep 2017 23:01:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1506092178-20351-1-git-send-email-arbab@linux.vnet.ibm.com>
References: <1506092178-20351-1-git-send-email-arbab@linux.vnet.ibm.com>
From: Balbir Singh <bsingharora@gmail.com>
Date: Sat, 23 Sep 2017 16:01:10 +1000
Message-ID: <CAKTCnzk6k3q8Pkh=REVFuiXuf=faORziwUBSkq_eOchM7J1BHA@mail.gmail.com>
Subject: Re: [PATCH] mm/device-public-memory: Fix edge case in _vm_normal_page()
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Reza Arbab <arbab@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>

On Sat, Sep 23, 2017 at 12:56 AM, Reza Arbab <arbab@linux.vnet.ibm.com> wro=
te:
> With device public pages at the end of my memory space, I'm getting
> output from _vm_normal_page():
>
> BUG: Bad page map in process migrate_pages  pte:c0800001ffff0d06 pmd:f95d=
3000
> addr:00007fff89330000 vm_flags:00100073 anon_vma:c0000000fa899320 mapping=
:          (null) index:7fff8933
> file:          (null) fault:          (null) mmap:          (null) readpa=
ge:          (null)
> CPU: 0 PID: 13963 Comm: migrate_pages Tainted: P    B      OE 4.14.0-rc1-=
wip #155
> Call Trace:
> [c0000000f965f910] [c00000000094d55c] dump_stack+0xb0/0xf4 (unreliable)
> [c0000000f965f950] [c0000000002b269c] print_bad_pte+0x28c/0x340
> [c0000000f965fa00] [c0000000002b59c0] _vm_normal_page+0xc0/0x140
> [c0000000f965fa20] [c0000000002b6e64] zap_pte_range+0x664/0xc10
> [c0000000f965fb00] [c0000000002b7858] unmap_page_range+0x318/0x670
> [c0000000f965fbd0] [c0000000002b8074] unmap_vmas+0x74/0xe0
> [c0000000f965fc20] [c0000000002c4a18] exit_mmap+0xe8/0x1f0
> [c0000000f965fce0] [c0000000000ecbdc] mmput+0xac/0x1f0
> [c0000000f965fd10] [c0000000000f62e8] do_exit+0x348/0xcd0
> [c0000000f965fdd0] [c0000000000f6d2c] do_group_exit+0x5c/0xf0
> [c0000000f965fe10] [c0000000000f6ddc] SyS_exit_group+0x1c/0x20
> [c0000000f965fe30] [c00000000000b184] system_call+0x58/0x6c
>
> The pfn causing this is the very last one. Correct the bounds check
> accordingly.
>
> Fixes: df6ad69838fc ("mm/device-public-memory: device memory cache cohere=
nt with CPU")
> Cc: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> Signed-off-by: Reza Arbab <arbab@linux.vnet.ibm.com>
> ---

Reviewed-by: Balbir Singh <bsingharora@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
