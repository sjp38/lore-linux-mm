Return-Path: <SRS0=6aBQ=PK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C704FC43387
	for <linux-mm@archiver.kernel.org>; Wed,  2 Jan 2019 10:03:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 516A02171F
	for <linux-mm@archiver.kernel.org>; Wed,  2 Jan 2019 10:03:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="dQKsnGW8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 516A02171F
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5E1B98E0018; Wed,  2 Jan 2019 05:03:31 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 592EB8E0002; Wed,  2 Jan 2019 05:03:31 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 481768E0018; Wed,  2 Jan 2019 05:03:31 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 205428E0002
	for <linux-mm@kvack.org>; Wed,  2 Jan 2019 05:03:31 -0500 (EST)
Received: by mail-io1-f70.google.com with SMTP id t13so30553838ioi.3
        for <linux-mm@kvack.org>; Wed, 02 Jan 2019 02:03:31 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=KMQfxB8N+IQ379B4k0aGWNqBUWDzzZVAp6aH4Ko6rDs=;
        b=oZwiq6ll7dnwQc5JE+IvniY3lFv527KXCFHzEbdQw0nlbtX4TvsRFy5ayqeKOtYo3B
         3BioUqrBreGtLInfGnniZVFjerI+kz4L9zPTqGB8j+niKFrTwyVfX00HJyARjcljq50T
         +r86UzfxvjCeD94n2iZlRCWSp22/p4VZ23DhgHyov5sBsiZ72lsr7vSZicsQxpJeXnXx
         a2tGMDWSm+l9PZQxjf9ZxfUdMUuf7qU8UrenGyNdczfRnfWvGd7Abg/Rdd6kEvXo56H8
         VfRSbCVhN2sm2ikna6hoI3jcNhcErebm6fgj4cmnpmYOiU3WrSue3SerWCknQYobMDnd
         1Ihw==
X-Gm-Message-State: AJcUukfy9nVXShEsSIlWH8UcVTs4i6DyJtVUGm7r/dKUiOmiMhnComSo
	nQfhLR9fh3vf9tVwAjpvVGcAU0eFc6v2w4ss62tVRmkfJbGOrKX7OAWYdqfRK5cSR/wwz0116YZ
	l63VAdABV9yq00OTNMo5ozKseaPt9jpC77suHU20UcUHjpsqM1vbpEYFIwcfOfTZsyk47e/keSh
	+0QzdeH9h6WLPDKMM9YAHkegV+F39Gb3qMs5yZSWT1AywELP/UfEVVr5Qmbr+07jg9gNk1vkuBK
	5ys0nihUdSXZ4syWo5M1Bh9WWBedi9H02OACdFFJ0deDGuizg3yjax31uERq7JP6wzOCr00EAKG
	/DKICmqAX3wDBpLqPA49Bbn+F6aw1RhwoW5nJq1kaBMEmHIf2rgTCl788YE7888bONkg9tEYlyp
	w
X-Received: by 2002:a6b:5c14:: with SMTP id z20mr29337274ioh.39.1546423410856;
        Wed, 02 Jan 2019 02:03:30 -0800 (PST)
X-Received: by 2002:a6b:5c14:: with SMTP id z20mr29337247ioh.39.1546423409812;
        Wed, 02 Jan 2019 02:03:29 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546423409; cv=none;
        d=google.com; s=arc-20160816;
        b=Nwjgj6TWC2zcCyIRwfGGFQPtRJuJK3F14w/yxY0ked6pjLZAKwu8QxsxbcAmyy+gzr
         lbRFcYI/SaG0r+cbvECW4lA5BYkcVDzHesLatCXH9dwsJQvoocbX9T2mYeYMZ5SB1sCi
         ZzyPmA8iuiYq0TvX8yMMCK6BuhfpyW6nJKVoG8ZPI3hAg8b22sCHf066RM89JyDbcOFJ
         ZJ9juyZ5wJfpJPXSENq8sCUVMWlmskI+25g8B7lmZpLg+oiTvBnU9hpVOdaaI9cajt8X
         oxJi106Y1Ut9iO7d6FT/asTXeagqEY30bzTA6BD6RM5VebV+HGkWSbKVB6PAgU7xBKgE
         duNA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=KMQfxB8N+IQ379B4k0aGWNqBUWDzzZVAp6aH4Ko6rDs=;
        b=jAdRAPlQAMcUVyEg2QclRXCjG/9TwnHS8mXY4Ty5FEQzZcBRp0fHC2I6UNvqfFVbGy
         pEbgEkfS7wVNIb7ZEcP26M1kva2LeHnhFP2/tnY0ALbpgYPrIetNhtEIOxVVjSprOw+i
         mZ/N+WfLvNEOaIfL6/cTTjldNfVbEmbhrIozyQrTbQWdH42W6XRfxx2TNRT37MDYo+gG
         je+RBq8UeEVqSoDSqs7fM9yw+7294qVb1Q2wenZmXF/LgqUCUTVUojRX9r81XovlXZiB
         q6a63hGDEyGqRQ6CPo/wRn+yrS/3tzn2KwUh6GXXVt0amXVULj/F1L7RWBYfEgIHGDdV
         tc/w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=dQKsnGW8;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m73sor58344799itm.20.2019.01.02.02.03.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 02 Jan 2019 02:03:29 -0800 (PST)
Received-SPF: pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=dQKsnGW8;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=KMQfxB8N+IQ379B4k0aGWNqBUWDzzZVAp6aH4Ko6rDs=;
        b=dQKsnGW83M6WuykbDGEzYUIdneBL9pJOlhbb3xeSKyrQyLVKB0Cxc2M6wE3YVcB5NB
         tIefvvGUhejeOiiuZNFQbWpf4WGfLlgG6T0H8JKEwUB/X79japWYRJ9z2SeEST7DeXi9
         2grU9glBnGIgcUCY4Vozwetow9HpBCiYpN0hYwVdLoxkiGZq0rZHX+TiXy6PDc/RpEBo
         qty7m9dhuo0vBxl4gLYV4T0VWzt/DG+dJJAtGE6tc0c5ZbW704fED6wsBQPdLYoVCP/u
         a39jVMLjgpnfkArkrHvwPXTDk6VSo5ugaWjE1+8oHMKkuZDTkjFYc3FerQaPilnjRGau
         KSOA==
X-Google-Smtp-Source: ALg8bN7jAluZ1QdobtTk1NywRyZXQBx6WzlGPUNPwWTYInStnQrwZV0tfNRHOE7t0VFcJlsm7bzFXfgQlHur4r6Gk9U=
X-Received: by 2002:a24:f14d:: with SMTP id q13mr25788541iti.166.1546423408892;
 Wed, 02 Jan 2019 02:03:28 -0800 (PST)
MIME-Version: 1.0
References: <000000000000ae384d057dc685c1@google.com> <1186a139-3a46-3311-5f72-bef02d403ee1@suse.cz>
 <CACT4Y+YbM7sVDg7XEpY-E9bW2dF8a6xd_Wp_dWCnCM02DbrbtA@mail.gmail.com> <b12b656c-04cb-6f34-e25a-f34d59e91316@suse.cz>
In-Reply-To: <b12b656c-04cb-6f34-e25a-f34d59e91316@suse.cz>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 2 Jan 2019 11:03:17 +0100
Message-ID:
 <CACT4Y+ZFnpWiBm80YRFUhjYmoTw6_1rH2=5cAj1kqR8p7Am7HQ@mail.gmail.com>
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
Message-ID: <20190102100317._9KxRUmnzHIJG0-8v3YJAX1iSr7D-qdvwRXtWTqQbi4@z>

On Wed, Jan 2, 2019 at 10:47 AM Vlastimil Babka <vbabka@suse.cz> wrote:
>
> On 1/2/19 10:42 AM, Dmitry Vyukov wrote:
> > On Wed, Jan 2, 2019 at 8:42 AM Vlastimil Babka <vbabka@suse.cz> wrote:
> >>
> >> On 12/24/18 4:48 PM, syzbot wrote:
> >>> Hello,
> >>>
> >>> syzbot found the following crash on:
> >>>
> >>> HEAD commit:    6a1d293238c1 Add linux-next specific files for 20181224
> >>> git tree:       linux-next
> >>> console output: https://syzkaller.appspot.com/x/log.txt?x=149a2add400000
> >>> kernel config:  https://syzkaller.appspot.com/x/.config?x=c190b602a5d2d731
> >>> dashboard link: https://syzkaller.appspot.com/bug?extid=a5fea9200aefd1cf4818
> >>> compiler:       gcc (GCC) 8.0.1 20180413 (experimental)
> >>> syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=1798bfb7400000
> >>> C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=17f4dc57400000
> >>>
> >>> IMPORTANT: if you fix the bug, please add the following tag to the commit:
> >>> Reported-by: syzbot+a5fea9200aefd1cf4818@syzkaller.appspotmail.com
> >>>
> >>> sshd (6016) used greatest stack depth: 15720 bytes left
> >>> kasan: CONFIG_KASAN_INLINE enabled
> >>> kasan: GPF could be caused by NULL-ptr deref or user memory access
> >>> general protection fault: 0000 [#1] PREEMPT SMP KASAN
> >>> CPU: 1 PID: 6032 Comm: syz-executor045 Not tainted 4.20.0-rc7-next-20181224
> >>> #187
> >>> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> >>> Google 01/01/2011
> >>> RIP: 0010:transparent_hugepage_enabled+0x8c/0x5e0 mm/huge_memory.c:69
> >>
> >> FTR, it was most certainly the same thing as here:
> >> https://marc.info/?l=linux-mm&m=154563777207477&w=2
> >
> > Thanks for the update. I see the fix is still not in linux-next, which has:
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
> > Let's wait until the patch is updated and then tell syzbot that "mm,
> > thp, proc: report THP eligibility for each vma" fixes this.
>
> Actually the fix was folded into the patch that caused the bug, and was
> already sent to and merged by Linus, commit
> 7635d9cbe8327e131a1d3d8517dc186c2796ce2e


But the email thread you referenced says that we need:

@@ -66,6 +66,8 @@ bool transparent_hugepage_enabled(struct vm_area_struct *vma)
 {
  if (vma_is_anonymous(vma))
  return __transparent_hugepage_enabled(vma);
+ if (!vma->vm_file || !vma->vm_file->f_mapping)
+ return false;
  if (shmem_mapping(vma->vm_file->f_mapping) && shmem_huge_enabled(vma))
  return __transparent_hugepage_enabled(vma);

and 7635d9cbe8327e131a1d3d8517dc186c2796ce2e contains:

+bool transparent_hugepage_enabled(struct vm_area_struct *vma)
+{
+       if (vma_is_anonymous(vma))
+               return __transparent_hugepage_enabled(vma);
+       if (vma_is_shmem(vma) && shmem_huge_enabled(vma))
+               return __transparent_hugepage_enabled(vma);
+
+       return false;
+}

What am I missing?



> >>> Code: 80 3c 02 00 0f 85 ae 04 00 00 4c 8b a3 a0 00 00 00 48 b8 00 00 00 00
> >>> 00 fc ff df 49 8d bc 24 b8 01 00 00 48 89 fa 48 c1 ea 03 <80> 3c 02 00 0f
> >>> 85 91 04 00 00 49 8b bc 24 b8 01 00 00 e8 2d 70 e6
> >>> RSP: 0018:ffff8881c2237138 EFLAGS: 00010202
> >>> RAX: dffffc0000000000 RBX: ffff8881c2bdbc60 RCX: 0000000000000000
> >>> RDX: 0000000000000037 RSI: ffffffff81c8fa1a RDI: 00000000000001b8
> >>> RBP: ffff8881c2237160 R08: ffffed10383b25ed R09: ffffed10383b25ec
> >>> R10: ffffed10383b25ec R11: ffff8881c1d92f63 R12: 0000000000000000
> >>> R13: ffff8881c2bdbd00 R14: dffffc0000000000 R15: 0000000000000f5e
> >>> FS:  0000000001a48880(0000) GS:ffff8881dad00000(0000) knlGS:0000000000000000
> >>> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> >>> CR2: 0000000020b58000 CR3: 00000001c2210000 CR4: 00000000001406e0
> >>> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> >>> DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
> >>> Call Trace:
> >>>   show_smap+0x167/0x580 fs/proc/task_mmu.c:805
> >>>   traverse+0x344/0x7b0 fs/seq_file.c:113
> >>>   seq_read+0xc76/0x1150 fs/seq_file.c:188
> >>>   do_loop_readv_writev fs/read_write.c:700 [inline]
> >>>   do_iter_read+0x4bc/0x670 fs/read_write.c:924
> >>>   vfs_readv+0x175/0x1c0 fs/read_write.c:986
> >>>   kernel_readv fs/splice.c:362 [inline]
> >>>   default_file_splice_read+0x539/0xb20 fs/splice.c:417
> >>>   do_splice_to+0x12e/0x190 fs/splice.c:880
> >>>   splice_direct_to_actor+0x31c/0x9d0 fs/splice.c:957
> >>>   do_splice_direct+0x2d4/0x420 fs/splice.c:1066
> >>>   do_sendfile+0x62a/0xe50 fs/read_write.c:1439
> >>>   __do_sys_sendfile64 fs/read_write.c:1494 [inline]
> >>>   __se_sys_sendfile64 fs/read_write.c:1486 [inline]
> >>>   __x64_sys_sendfile64+0x15d/0x250 fs/read_write.c:1486
> >>>   do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
> >>>   entry_SYSCALL_64_after_hwframe+0x49/0xbe
> >>> RIP: 0033:0x440089
> >>> Code: 18 89 d0 c3 66 2e 0f 1f 84 00 00 00 00 00 0f 1f 00 48 89 f8 48 89 f7
> >>> 48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff
> >>> ff 0f 83 5b 14 fc ff c3 66 2e 0f 1f 84 00 00 00 00
> >>> RSP: 002b:00007fff3d710a18 EFLAGS: 00000213 ORIG_RAX: 0000000000000028
> >>> RAX: ffffffffffffffda RBX: 00007fff3d710a20 RCX: 0000000000440089
> >>> RDX: 0000000020b58000 RSI: 0000000000000003 RDI: 0000000000000003
> >>> RBP: 00000000006ca018 R08: 0000000000000010 R09: 65732f636f72702f
> >>> R10: 000000000000ffff R11: 0000000000000213 R12: 0000000000401970
> >>> R13: 0000000000401a00 R14: 0000000000000000 R15: 0000000000000000
> >>> Modules linked in:
> >>> ---[ end trace faf026efd8795e93 ]---
> >>> RIP: 0010:transparent_hugepage_enabled+0x8c/0x5e0 mm/huge_memory.c:69
> >>> Code: 80 3c 02 00 0f 85 ae 04 00 00 4c 8b a3 a0 00 00 00 48 b8 00 00 00 00
> >>> 00 fc ff df 49 8d bc 24 b8 01 00 00 48 89 fa 48 c1 ea 03 <80> 3c 02 00 0f
> >>> 85 91 04 00 00 49 8b bc 24 b8 01 00 00 e8 2d 70 e6
> >>> RSP: 0018:ffff8881c2237138 EFLAGS: 00010202
> >>> RAX: dffffc0000000000 RBX: ffff8881c2bdbc60 RCX: 0000000000000000
> >>> RDX: 0000000000000037 RSI: ffffffff81c8fa1a RDI: 00000000000001b8
> >>> RBP: ffff8881c2237160 R08: ffffed10383b25ed R09: ffffed10383b25ec
> >>> R10: ffffed10383b25ec R11: ffff8881c1d92f63 R12: 0000000000000000
> >>> R13: ffff8881c2bdbd00 R14: dffffc0000000000 R15: 0000000000000f5e
> >>> FS:  0000000001a48880(0000) GS:ffff8881dad00000(0000) knlGS:0000000000000000
> >>> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> >>> CR2: 0000000020b58000 CR3: 00000001c2210000 CR4: 00000000001406e0
> >>> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> >>> DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
> >>>
> >>>
> >>> ---
> >>> This bug is generated by a bot. It may contain errors.
> >>> See https://goo.gl/tpsmEJ for more information about syzbot.
> >>> syzbot engineers can be reached at syzkaller@googlegroups.com.
> >>>
> >>> syzbot will keep track of this bug report. See:
> >>> https://goo.gl/tpsmEJ#bug-status-tracking for how to communicate with
> >>> syzbot.
> >>> syzbot can test patches for this bug, for details see:
> >>> https://goo.gl/tpsmEJ#testing-patches
>

