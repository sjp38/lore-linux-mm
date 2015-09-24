Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f169.google.com (mail-ob0-f169.google.com [209.85.214.169])
	by kanga.kvack.org (Postfix) with ESMTP id D86B882F7F
	for <linux-mm@kvack.org>; Thu, 24 Sep 2015 15:10:40 -0400 (EDT)
Received: by obbmp4 with SMTP id mp4so65845699obb.3
        for <linux-mm@kvack.org>; Thu, 24 Sep 2015 12:10:40 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id t142si7330566oie.82.2015.09.24.12.10.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Sep 2015 12:10:40 -0700 (PDT)
Message-ID: <5604489F.8070506@oracle.com>
Date: Thu, 24 Sep 2015 15:01:51 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: Multiple potential races on vma->vm_flags
References: <55EC9221.4040603@oracle.com>	<20150907114048.GA5016@node.dhcp.inet.fi>	<55F0D5B2.2090205@oracle.com>	<20150910083605.GB9526@node.dhcp.inet.fi>	<CAAeHK+xSFfgohB70qQ3cRSahLOHtamCftkEChEgpFpqAjb7Sjg@mail.gmail.com>	<20150911103959.GA7976@node.dhcp.inet.fi>	<alpine.LSU.2.11.1509111734480.7660@eggly.anvils>	<55F8572D.8010409@oracle.com>	<20150924131141.GA7623@redhat.com>	<5604247A.7010303@oracle.com>	<20150924172609.GA29842@redhat.com> <CAPAsAGx660uSk=WbpWmZR9FpSFXmp3G9yXxRXu65gozu3qT63g@mail.gmail.com>
In-Reply-To: <CAPAsAGx660uSk=WbpWmZR9FpSFXmp3G9yXxRXu65gozu3qT63g@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <ryabinin.a.a@gmail.com>, Oleg Nesterov <oleg@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrey Konovalov <andreyknvl@google.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Vlastimil Babka <vbabka@suse.cz>

On 09/24/2015 02:52 PM, Andrey Ryabinin wrote:
> Sasha, could you confirm that in your kernel mmu_notifier_mm field has
> 0x4c8 offset?
> I would use gdb for that:
> gdb vmlinux
> (gdb) p/x &(((struct mm_struct*)0)->mmu_notifier_mm)

(gdb) p/x &(((struct mm_struct*)0)->mmu_notifier_mm)
$1 = 0x4c8


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
