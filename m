Return-Path: <SRS0=6aBQ=PK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9E0A8C43387
	for <linux-mm@archiver.kernel.org>; Wed,  2 Jan 2019 10:32:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4610E218A4
	for <linux-mm@archiver.kernel.org>; Wed,  2 Jan 2019 10:32:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="aTP0E6Ou"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4610E218A4
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D6F208E001B; Wed,  2 Jan 2019 05:32:21 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CF7118E0002; Wed,  2 Jan 2019 05:32:21 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BC0368E001B; Wed,  2 Jan 2019 05:32:21 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8F98E8E0002
	for <linux-mm@kvack.org>; Wed,  2 Jan 2019 05:32:21 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id 123so35656540itv.6
        for <linux-mm@kvack.org>; Wed, 02 Jan 2019 02:32:21 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=+D4ccszRSj/KLpoKgCTt9tBlEN0s5ecSJaxVrk2vx6Q=;
        b=sjgKtXyVkPFMtZYFBDUpmCvZBgqd4mKcbVPkXduYx1rI0dYVTg1d7h9QQymZf9i8CN
         NfnpC+LspRBINKgD7+5/v7s9NxQMp/EjpCB7QZ2uf5+XWbNp0NY3yBGbj4Lp/zGSVD9H
         K8Lx6fScOg4x6Js/Y9hIKrULbY/igBA9jHuYuuv6CMPXokYLgSzILS4gKVLbkImucjE5
         PNUNubjEQJedYrYioFprnVx/9GRrHnMuble+mslYTrBuvLjK0WU3VJgxsh1xB0ITPQls
         hxJob00HqdPikCkGYG2vQl8n4MltXzEeG2A61ORR8ETAH8m8+o3hNaGYSpB6rVXHimoG
         gk/w==
X-Gm-Message-State: AJcUukd/b1o51CMaQH8gjYm8lFM9hI/8jS0UsMS8UpAqvZMVvTjSuFF0
	X3mvvIxKdDHBfdhk3+ZmtptajRDfZLx1V8pXJSVMWUDNmPsXzm2TLr6YOiLxM87C37Q6XAIc7XU
	wwUG2LUmgwaYedXQ7UcF90WId4NEya+TCcV/2QQgLzv7A0qQPI6R+BNVoKH9mLnmqOO/joCZztm
	IpYADyzZrfTli04uHhiA6692TWnqylUMDWGswf8b9v8PsTxXopptMAN+bDNvhkdwalqPtbRFNlO
	ffrf0w6FBQkfOVbf1FUE1om0caP/4VX8v/AnIswkMW2eigCIgaQnooGiNAup5ZMBqC+Ia3vpnLv
	FSNjuLfRpAnTRG1wjQ21H95p5InPthkSYVkRH7+WBzr8WNp9VSkCRVAh/THgOJddtGE6D9dzFHJ
	A
X-Received: by 2002:a02:ba01:: with SMTP id z1mr24242320jan.100.1546425141344;
        Wed, 02 Jan 2019 02:32:21 -0800 (PST)
X-Received: by 2002:a02:ba01:: with SMTP id z1mr24242299jan.100.1546425140507;
        Wed, 02 Jan 2019 02:32:20 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546425140; cv=none;
        d=google.com; s=arc-20160816;
        b=VwWiIaOKf0H2LWqrcVsQMPtDm4NpOYtr86v+ACh+NuWz7b/EU6N3bKUDKdj9V4EQgG
         JX0q2hQ3Iw+0VwMb24h6PaO6u5dad3NCMB0LXoSnMdMsDk6Gk0z7yUtsP583y1hJlPH1
         gk0FTOSMn0PZcKUX0fa+9k7sQBTinIwevQtF9y81D4mzWR+nOCgrDGQzhSuEUO1DhbLM
         xEYN4T1ev5qDlfae7aGB513YvBzM12DWRMaDgx0fbf4IDwA4Ib8jHPcz6Vhfggippp1Z
         +oo3KuarQ/V4TjlbnONnEHQ/g7U6+Q6aihJCPNcZE19UA9jvvNdNE2sJaIXHzB7+ZMb+
         HYiA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=+D4ccszRSj/KLpoKgCTt9tBlEN0s5ecSJaxVrk2vx6Q=;
        b=oUy2t+EbHdGb9EqfA3BkVe6GvKy7VT7Up6b3jMBaBYkQkovKvei2m+lrc7fBsErJp4
         vmzXWU74j43KLxtYIc3H+WYfXoI4JNGa6mnFEQqO/4DzwSFMQDxZfN/Bj103TWantYdy
         +LavB+IwKFkZicJZT2ONBzV6wWaqxLnI0nzXryaCYdZpYH6ILzs8Q1e+RuAS522HCfiG
         1hh9kx9inML5EuNgZD64X1SYWe1Gv4gpI64Zrk/hMNHI2re5IH12SLO2uUdmIzXaGl4+
         0gomg9+lHNK09w5vpUJ7VceXTnTfss1q09Ft5NDgFOMSLdBPFVQZ8MXKQqjKBSdGqAAj
         8iRg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=aTP0E6Ou;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v20sor37929013ita.10.2019.01.02.02.32.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 02 Jan 2019 02:32:20 -0800 (PST)
Received-SPF: pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=aTP0E6Ou;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=+D4ccszRSj/KLpoKgCTt9tBlEN0s5ecSJaxVrk2vx6Q=;
        b=aTP0E6OukAwr5mmMYJd+C9ufxSUS9M7mYrRORqRtN/+5Wq0J5LZRUK5RikQ9RpEXWy
         e7fDvUIBFYR+c43b8YG0XaIiaWFIWaWMsQB5g567hhO722kIVZEKMVShK34xxpixjrdi
         vxuy2M52qs/o4Xw44wv5WFNtLS3sEmqwKoPT9A39I5ljCXxWVy5vOdZnKCaPLF4PfKtn
         i00c+Sp4I1ENGPyd/fFNpq1K/z+8UcZcFccAo3odilN6pbMUZnOLBK5xMPARY3Ld79Zx
         v98b3OuBgdaIV05i3vrHmkM3SGyc1XDWiqdkD5GIk0WJSCvUVlImE2072Wiuax0LyKtm
         kclg==
X-Google-Smtp-Source: ALg8bN6C35S6IAj1IVO0roJaJGKpssp9DFrLJsTAnLOVTMVl5OYEtTsduHNW7kRfKodK5+VgOOjmeY4lW6XEVCtmvfs=
X-Received: by 2002:a24:6511:: with SMTP id u17mr5477679itb.12.1546425139839;
 Wed, 02 Jan 2019 02:32:19 -0800 (PST)
MIME-Version: 1.0
References: <000000000000ae384d057dc685c1@google.com> <1186a139-3a46-3311-5f72-bef02d403ee1@suse.cz>
 <CACT4Y+YbM7sVDg7XEpY-E9bW2dF8a6xd_Wp_dWCnCM02DbrbtA@mail.gmail.com>
 <b12b656c-04cb-6f34-e25a-f34d59e91316@suse.cz> <CACT4Y+ZFnpWiBm80YRFUhjYmoTw6_1rH2=5cAj1kqR8p7Am7HQ@mail.gmail.com>
 <a04f4ed2-da5d-99ec-5d8c-b617966a4728@suse.cz>
In-Reply-To: <a04f4ed2-da5d-99ec-5d8c-b617966a4728@suse.cz>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 2 Jan 2019 11:32:08 +0100
Message-ID:
 <CACT4Y+aLQ_wYBvcnevLXGUy9WBgrdpV43vhwTKgwmNrEfRTf6A@mail.gmail.com>
Subject: Re: general protection fault in transparent_hugepage_enabled
To: Vlastimil Babka <vbabka@suse.cz>
Cc: syzbot <syzbot+a5fea9200aefd1cf4818@syzkaller.appspotmail.com>, 
	Andrew Morton <akpm@linux-foundation.org>, 
	"Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Hugh Dickins <hughd@google.com>, 
	Jerome Glisse <jglisse@redhat.com>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, 
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, LKML <linux-kernel@vger.kernel.org>, 
	Linux-MM <linux-mm@kvack.org>, Michal Hocko <mhocko@suse.com>, 
	David Rientjes <rientjes@google.com>, Stephen Rothwell <sfr@canb.auug.org.au>, 
	syzkaller-bugs <syzkaller-bugs@googlegroups.com>, Matthew Wilcox <willy@infradead.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190102103208.O7L7eQJoBngJSkuhfe7wyLf_YG7AfycPU6-gKOfvKc4@z>

On Wed, Jan 2, 2019 at 11:24 AM Vlastimil Babka <vbabka@suse.cz> wrote:
>
> On 1/2/19 11:03 AM, Dmitry Vyukov wrote:
> > On Wed, Jan 2, 2019 at 10:47 AM Vlastimil Babka <vbabka@suse.cz> wrote:
> >>
> >> Actually the fix was folded into the patch that caused the bug, and was
> >> already sent to and merged by Linus, commit
> >> 7635d9cbe8327e131a1d3d8517dc186c2796ce2e
> >
> >
> > But the email thread you referenced says that we need:
> >
> > @@ -66,6 +66,8 @@ bool transparent_hugepage_enabled(struct vm_area_struct *vma)
> >  {
> >   if (vma_is_anonymous(vma))
> >   return __transparent_hugepage_enabled(vma);
> > + if (!vma->vm_file || !vma->vm_file->f_mapping)
> > + return false;
> >   if (shmem_mapping(vma->vm_file->f_mapping) && shmem_huge_enabled(vma))
> >   return __transparent_hugepage_enabled(vma);
> >
> > and 7635d9cbe8327e131a1d3d8517dc186c2796ce2e contains:
> >
> > +bool transparent_hugepage_enabled(struct vm_area_struct *vma)
> > +{
> > +       if (vma_is_anonymous(vma))
> > +               return __transparent_hugepage_enabled(vma);
> > +       if (vma_is_shmem(vma) && shmem_huge_enabled(vma))
> > +               return __transparent_hugepage_enabled(vma);
> > +
> > +       return false;
> > +}
> >
> > What am I missing?
>
> Ah, the solution with vma_is_shmem() appeared later in the thread:
> https://marc.info/?l=linux-mm&m=154567747315893&w=2

Ah, thanks, just wanted to make sure I understand what happens here.
Then let's record this in trackable way:

#syz fix: mm, thp, proc: report THP eligibility for each vma

> >>>>> Code: 80 3c 02 00 0f 85 ae 04 00 00 4c 8b a3 a0 00 00 00 48 b8 00 00 00 00
> >>>>> 00 fc ff df 49 8d bc 24 b8 01 00 00 48 89 fa 48 c1 ea 03 <80> 3c 02 00 0f
> >>>>> 85 91 04 00 00 49 8b bc 24 b8 01 00 00 e8 2d 70 e6
> >>>>> RSP: 0018:ffff8881c2237138 EFLAGS: 00010202
> >>>>> RAX: dffffc0000000000 RBX: ffff8881c2bdbc60 RCX: 0000000000000000
> >>>>> RDX: 0000000000000037 RSI: ffffffff81c8fa1a RDI: 00000000000001b8
> >>>>> RBP: ffff8881c2237160 R08: ffffed10383b25ed R09: ffffed10383b25ec
> >>>>> R10: ffffed10383b25ec R11: ffff8881c1d92f63 R12: 0000000000000000
> >>>>> R13: ffff8881c2bdbd00 R14: dffffc0000000000 R15: 0000000000000f5e
> >>>>> FS:  0000000001a48880(0000) GS:ffff8881dad00000(0000) knlGS:0000000000000000
> >>>>> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> >>>>> CR2: 0000000020b58000 CR3: 00000001c2210000 CR4: 00000000001406e0
> >>>>> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> >>>>> DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
> >>>>> Call Trace:
> >>>>>   show_smap+0x167/0x580 fs/proc/task_mmu.c:805
> >>>>>   traverse+0x344/0x7b0 fs/seq_file.c:113
> >>>>>   seq_read+0xc76/0x1150 fs/seq_file.c:188
> >>>>>   do_loop_readv_writev fs/read_write.c:700 [inline]
> >>>>>   do_iter_read+0x4bc/0x670 fs/read_write.c:924
> >>>>>   vfs_readv+0x175/0x1c0 fs/read_write.c:986
> >>>>>   kernel_readv fs/splice.c:362 [inline]
> >>>>>   default_file_splice_read+0x539/0xb20 fs/splice.c:417
> >>>>>   do_splice_to+0x12e/0x190 fs/splice.c:880
> >>>>>   splice_direct_to_actor+0x31c/0x9d0 fs/splice.c:957
> >>>>>   do_splice_direct+0x2d4/0x420 fs/splice.c:1066
> >>>>>   do_sendfile+0x62a/0xe50 fs/read_write.c:1439
> >>>>>   __do_sys_sendfile64 fs/read_write.c:1494 [inline]
> >>>>>   __se_sys_sendfile64 fs/read_write.c:1486 [inline]
> >>>>>   __x64_sys_sendfile64+0x15d/0x250 fs/read_write.c:1486
> >>>>>   do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
> >>>>>   entry_SYSCALL_64_after_hwframe+0x49/0xbe
> >>>>> RIP: 0033:0x440089
> >>>>> Code: 18 89 d0 c3 66 2e 0f 1f 84 00 00 00 00 00 0f 1f 00 48 89 f8 48 89 f7
> >>>>> 48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff
> >>>>> ff 0f 83 5b 14 fc ff c3 66 2e 0f 1f 84 00 00 00 00
> >>>>> RSP: 002b:00007fff3d710a18 EFLAGS: 00000213 ORIG_RAX: 0000000000000028
> >>>>> RAX: ffffffffffffffda RBX: 00007fff3d710a20 RCX: 0000000000440089
> >>>>> RDX: 0000000020b58000 RSI: 0000000000000003 RDI: 0000000000000003
> >>>>> RBP: 00000000006ca018 R08: 0000000000000010 R09: 65732f636f72702f
> >>>>> R10: 000000000000ffff R11: 0000000000000213 R12: 0000000000401970
> >>>>> R13: 0000000000401a00 R14: 0000000000000000 R15: 0000000000000000
> >>>>> Modules linked in:
> >>>>> ---[ end trace faf026efd8795e93 ]---
> >>>>> RIP: 0010:transparent_hugepage_enabled+0x8c/0x5e0 mm/huge_memory.c:69
> >>>>> Code: 80 3c 02 00 0f 85 ae 04 00 00 4c 8b a3 a0 00 00 00 48 b8 00 00 00 00
> >>>>> 00 fc ff df 49 8d bc 24 b8 01 00 00 48 89 fa 48 c1 ea 03 <80> 3c 02 00 0f
> >>>>> 85 91 04 00 00 49 8b bc 24 b8 01 00 00 e8 2d 70 e6
> >>>>> RSP: 0018:ffff8881c2237138 EFLAGS: 00010202
> >>>>> RAX: dffffc0000000000 RBX: ffff8881c2bdbc60 RCX: 0000000000000000
> >>>>> RDX: 0000000000000037 RSI: ffffffff81c8fa1a RDI: 00000000000001b8
> >>>>> RBP: ffff8881c2237160 R08: ffffed10383b25ed R09: ffffed10383b25ec
> >>>>> R10: ffffed10383b25ec R11: ffff8881c1d92f63 R12: 0000000000000000
> >>>>> R13: ffff8881c2bdbd00 R14: dffffc0000000000 R15: 0000000000000f5e
> >>>>> FS:  0000000001a48880(0000) GS:ffff8881dad00000(0000) knlGS:0000000000000000
> >>>>> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> >>>>> CR2: 0000000020b58000 CR3: 00000001c2210000 CR4: 00000000001406e0
> >>>>> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> >>>>> DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
> >>>>>
> >>>>>
> >>>>> ---
> >>>>> This bug is generated by a bot. It may contain errors.
> >>>>> See https://goo.gl/tpsmEJ for more information about syzbot.
> >>>>> syzbot engineers can be reached at syzkaller@googlegroups.com.
> >>>>>
> >>>>> syzbot will keep track of this bug report. See:
> >>>>> https://goo.gl/tpsmEJ#bug-status-tracking for how to communicate with
> >>>>> syzbot.
> >>>>> syzbot can test patches for this bug, for details see:
> >>>>> https://goo.gl/tpsmEJ#testing-patches
> >>
>

