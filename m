Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0D3D18E0002
	for <linux-mm@kvack.org>; Mon, 14 Jan 2019 10:45:45 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id k90so25045830qte.0
        for <linux-mm@kvack.org>; Mon, 14 Jan 2019 07:45:45 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y15sor85061805qtj.70.2019.01.14.07.45.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 14 Jan 2019 07:45:44 -0800 (PST)
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
Message-ID: <5298bfcc-0cbc-01e8-85b2-087a380fd3fe@lca.pw>
Date: Mon, 14 Jan 2019 10:45:42 -0500
MIME-Version: 1.0
In-Reply-To: <GBn2paWQ0Uy0COgTeJsgmC18Faw0x_yNIog8gpuC5TJ4kCn_IUH1EnHJW0mQeo3Qy5MMcpMzyw9Yer3lxyWYgtk5TJx8I3sJK4oVlIJh38s=@protonmail.ch>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Esme <esploit@protonmail.ch>, "dgilbert@interlog.com" <dgilbert@interlog.com>
Cc: David Lechner <david@lechnology.com>, Michel Lespinasse <walken@google.com>, Andrew Morton <akpm@linux-foundation.org>, "jejb@linux.ibm.com" <jejb@linux.ibm.com>, "martin.petersen@oracle.com" <martin.petersen@oracle.com>, "joeypabalinas@gmail.com" <joeypabalinas@gmail.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>



On 1/14/19 1:23 AM, Esme wrote:
> I did not yet verify the previous branches but did tune out kmemleak (CONFIG_DEBUG_MEMLEAK no longer set) as it seemed a bit obtrusive in this matter, this is what I see now (note redzone?).
> /Esme
> 
>   114.826116] =============================================================================
> [  114.828121] BUG kmalloc-64 (Tainted: G        W        ): Padding overwritten. 0x000000006913c65d-0x000000006e410492
> [  114.830551] -----------------------------------------------------------------------------
> [  114.830551]
> [  114.832755] INFO: Slab 0x0000000054f47c55 objects=19 used=19 fp=0x          (null) flags=0x1fffc0000010200
> [  114.835063] CPU: 0 PID: 6310 Comm: x Tainted: G    B   W         5.0.0-rc2 #15
> [  114.836829] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.11.1-1ubuntu1 04/01/2014
> [  114.838847] Call Trace:
> [  114.839497]  dump_stack+0x1d8/0x2c6
> [  114.840274]  ? dump_stack_print_info.cold.1+0x20/0x20
> [  114.841402]  slab_err+0xab/0xcf
> [  114.842103]  ? __asan_report_load1_noabort+0x14/0x20
> [  114.843244]  ? memchr_inv+0x2c1/0x330
> [  114.844059]  slab_pad_check.part.50.cold.87+0x27/0x81

Confused again. Those slab_pad_check() looks like only with SLUB, but you said
you used SLAB. What else did you change?
