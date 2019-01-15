Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id B55508E0002
	for <linux-mm@kvack.org>; Tue, 15 Jan 2019 00:31:23 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id p79so1338161qki.15
        for <linux-mm@kvack.org>; Mon, 14 Jan 2019 21:31:23 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v18sor86608493qtp.42.2019.01.14.21.31.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 14 Jan 2019 21:31:22 -0800 (PST)
Subject: Re: [PATCH v2] rbtree: fix the red root
References: <20190111181600.GJ6310@bombadil.infradead.org>
 <20190111205843.25761-1-cai@lca.pw>
 <a783f23d-77ab-a7d3-39d1-4008d90094c3@lechnology.com>
 <CANN689G0zbk7sMbQ+p9NQGQ=NWq-Q0mQOOjeFkLp19YrTfgcLg@mail.gmail.com>
 <864d6b85-3336-4040-7c95-7d9615873777@lechnology.com>
 <b1033d96-ebdd-e791-650a-c6564f030ce1@lca.pw>
 <8v11ZOLyufY7NLAHDFApGwXOO_wGjVHtsbw1eiZ__YvI9EZCDe_4FNmlp0E-39lnzGQHhHAczQ6Q6lQPzVU2V6krtkblM8IFwIXPHZCuqGE=@protonmail.ch>
 <c6265fc0-4089-9d1a-ba7c-b267b847747e@interlog.com>
 <UKsodHRZU8smIdO2MHHL4Yzde_YB4iWX43TaHI1uY2tMo4nii4ucbaw4XC31XIY-Pe4oEovjF62qbkeMsIMTrvT1TdCCP4Fs_fxciAzXYVc=@protonmail.ch>
 <ad591828-76e8-324b-6ab8-dc87e4390f64@interlog.com>
 <GBn2paWQ0Uy0COgTeJsgmC18Faw0x_yNIog8gpuC5TJ4kCn_IUH1EnHJW0mQeo3Qy5MMcpMzyw9Yer3lxyWYgtk5TJx8I3sJK4oVlIJh38s=@protonmail.ch>
From: Qian Cai <cai@lca.pw>
Message-ID: <dac115ca-d6ed-dfc0-161a-8e51a7f93e00@lca.pw>
Date: Tue, 15 Jan 2019 00:31:20 -0500
MIME-Version: 1.0
In-Reply-To: <GBn2paWQ0Uy0COgTeJsgmC18Faw0x_yNIog8gpuC5TJ4kCn_IUH1EnHJW0mQeo3Qy5MMcpMzyw9Yer3lxyWYgtk5TJx8I3sJK4oVlIJh38s=@protonmail.ch>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Esme <esploit@protonmail.ch>, "dgilbert@interlog.com" <dgilbert@interlog.com>
Cc: David Lechner <david@lechnology.com>, Michel Lespinasse <walken@google.com>, Andrew Morton <akpm@linux-foundation.org>, "jejb@linux.ibm.com" <jejb@linux.ibm.com>, "martin.petersen@oracle.com" <martin.petersen@oracle.com>, "joeypabalinas@gmail.com" <joeypabalinas@gmail.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>


> [  114.913404] Padding 000000006913c65d: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [  114.915437] Padding 000000002d53f25c: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [  114.917390] Padding 0000000078f7d621: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [  114.919402] Padding 0000000063547658: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [  114.921414] Padding 000000001a301f4e: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [  114.923364] Padding 0000000046589d24: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [  114.925340] Padding 0000000008fb13da: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [  114.927291] Padding 00000000ae5cc298: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [  114.929239] Padding 00000000d49cc239: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [  114.931177] Padding 00000000d66ad6f5: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [  114.933110] Padding 00000000069ad671: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [  114.934986] Padding 00000000ffaf648c: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [  114.936895] Padding 00000000c96d1b58: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [  114.938848] Padding 00000000768e4920: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [  114.940965] Padding 000000000d06b43c: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [  114.942890] Padding 00000000af5ae9fa: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [  114.944790] Padding 000000006b526f1e: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [  114.946727] Padding 000000009c8dffe3: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................

Another testing angle,

It might be something is doing __GFP_ZERO and overwriting those slabs. This also
matched the red root corruption, since RB_RED is bit 0.

One thing to try is to enable page_owner=on in the command-line, and then obtain
sorted_page_owner.txt before and after running the reproducer.

$ cd tools/vm
$ make page_owner_sort

$ cat /sys/kernel/debug/page_owner > page_owner_full.txt
$ grep -v ^PFN page_owner_full.txt > page_owner.txt
$ ./page_owner_sort page_owner.txt sorted_page_owner.txt
