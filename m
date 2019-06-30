Return-Path: <SRS0=QnEd=U5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5DBD1C5B576
	for <linux-mm@archiver.kernel.org>; Sun, 30 Jun 2019 21:15:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C895C208C3
	for <linux-mm@archiver.kernel.org>; Sun, 30 Jun 2019 21:15:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="rvN4V9N/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C895C208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3004D6B0003; Sun, 30 Jun 2019 17:15:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2D7408E0003; Sun, 30 Jun 2019 17:15:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1EDC68E0002; Sun, 30 Jun 2019 17:15:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f79.google.com (mail-io1-f79.google.com [209.85.166.79])
	by kanga.kvack.org (Postfix) with ESMTP id F130A6B0003
	for <linux-mm@kvack.org>; Sun, 30 Jun 2019 17:15:19 -0400 (EDT)
Received: by mail-io1-f79.google.com with SMTP id j18so13183328ioj.4
        for <linux-mm@kvack.org>; Sun, 30 Jun 2019 14:15:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=ZoRpbZ+jo27grfNyA22UmsWNliO+K/lB3EZN2rYAvjY=;
        b=rBv59+2ko+hGoNwBs4/IdC26AQ6PGho78Not91AbvlwwfDk4ZDNVppzDBOby4Ukrnb
         k4pwYfPgAUeZoqosobk0306B3ctNtwzyTLiWUhADoxWnhRqK9sdCZqV///0MNcflR2jW
         rMo0A3LGliKXHV6LuLuwzuKjwhYtCSfXLE1lzzD2zOKb+gkEpStnbDP1HQDwl+VyBflW
         Pf3eg3oSavNDlmnbSPhUMlym5KO4lO9BJPcizBIbiFLytFxnmiEZ1ERQHz+BV6zEIqWO
         sNfuUJ6+4VtfyuyZa0NLUNAiQ6dN9VwmBS657Nw20DuTvUkRNyGzorKSheKt+Jzrg8cK
         JXdg==
X-Gm-Message-State: APjAAAXQZITDy+Up6Q+dw4hfH4Z3IIu26CCIZFSIycxyA3YRXiZIpsVR
	9FZ4ZKKHhUlNjJaH56k/NynN/fGWsTQcE1Q6Y0/UWBWhZ7jsuobaSbav+5f76JG8zaBwMJRRvF6
	l0//gnqgSBR/pGYpJKLzwB1rH21UKO0OE7GY3c7y/f673OGjmzd+xIbf3W40VH70rPg==
X-Received: by 2002:a02:242a:: with SMTP id f42mr24403941jaa.42.1561929319656;
        Sun, 30 Jun 2019 14:15:19 -0700 (PDT)
X-Received: by 2002:a02:242a:: with SMTP id f42mr24403826jaa.42.1561929318091;
        Sun, 30 Jun 2019 14:15:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561929318; cv=none;
        d=google.com; s=arc-20160816;
        b=vPs6sz/F+yr/XwrcnrXTuCHjuKHyV6zogl++ber6pZD20VSYDTDZ9YdjK4IwJzU675
         LN/mb5ke/Nlzdf5BNn4033N4P/UBe1JyOKiNe+B7DKOoHyz8sjR9UIH/LFAhJsSyuRPD
         ZR1mpcDUWGY82u5sT76OTc2gxZwgdlPX2l2dpv1zqD1s0X3S1u5AAitVRmShcFqiaxej
         ysiDw7XozLA+ToKwYUGJQN0gmwRG7bE2j7Ol7wK39lKKXc1uluPPZfXIJ2sXJfPdor0N
         O62yOAocIzpXfgE4yNSrOeKrtnx8PxIYVKfd1USJXauUx/7I36gkZRsMQaIyUlbVsa40
         +3nQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=ZoRpbZ+jo27grfNyA22UmsWNliO+K/lB3EZN2rYAvjY=;
        b=eQfm5WaH7/afmg+pPz5p2BzqrnRgAdgnRA0NGpqXqexoLxkTvxF8muWaUbrjfEcKho
         80NnDw0Dec7g8F5dg0i4eEeYEdr0h5g5r+F5cfQBxHae9xfn0hQ3bUX4REuRLFHvQgVG
         3L8NOaMnafXv+n2WIKpysj2wrSa3tqcOOIEl9iaGZ1dl0Pz5PmSgRSChcfJu74YyuB6k
         HZ13v2UOaAmOOxupe4x1+8/allrlw66kTldTdtnHHNQv4HqED3M54VgXTFLefbgMqkjw
         RyIphkUYOCF2N3FsyFFoTiL4jmP4Ca8r2KSdpSSHXp2QiOMG9tsbjuQJ97//iUgI5Okc
         U7cA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="rvN4V9N/";
       spf=pass (google.com: domain of mikhail.v.gavrilov@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mikhail.v.gavrilov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 8sor22845514jae.3.2019.06.30.14.15.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 30 Jun 2019 14:15:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of mikhail.v.gavrilov@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="rvN4V9N/";
       spf=pass (google.com: domain of mikhail.v.gavrilov@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mikhail.v.gavrilov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=ZoRpbZ+jo27grfNyA22UmsWNliO+K/lB3EZN2rYAvjY=;
        b=rvN4V9N/YLdA9PgcL/e+Ozwifu57xnLz85yVP8a/8jYiQ4T/U2UC9ztMuZd0sdev7o
         U+lKMd2HrkdTO1XwqMzWg3vzuytnaJjErp52iDWuUdt53U08L6twit7i9O3BHHcWAo06
         YxWCWlS9DQ62B90cnRAo003+EQt7Qw+FA60ZQvolaSgjlu+3Fxlyy/VV4kUT2Plbln4z
         xz4N9yjarjcQ48HhkWhURV4rJqnGdnQNqZaGtOGRDTBntwMM5N344+OA4ar6l89WMUpM
         7yre6CxV0lvC1VTSQD2QAIWlr6fglnNiUHjXHQme1WeLwVnSb1u0jwPB6tId44YXiJVZ
         3E7w==
X-Google-Smtp-Source: APXvYqy93TPv9/gbw8yfD4u70Pgq/BTgjQ7NLNJ0LJ8ZTLFSzyvdyj9iB2xbDxNizlMCrGkqhq6HtGoUXVcYfPy5LH8=
X-Received: by 2002:a02:16c5:: with SMTP id a188mr25227077jaa.86.1561929317301;
 Sun, 30 Jun 2019 14:15:17 -0700 (PDT)
MIME-Version: 1.0
References: <CABXGCsN9mYmBD-4GaaeW_NrDu+FDXLzr_6x+XNxfmFV6QkYCDg@mail.gmail.com>
 <CABXGCsNq4xTFeeLeUXBj7vXBz55aVu31W9q74r+pGM83DrPjfA@mail.gmail.com>
 <20190529180931.GI18589@dhcp22.suse.cz> <CABXGCsPrk=WJzms_H+-KuwSRqWReRTCSs-GLMDsjUG_-neYP0w@mail.gmail.com>
 <CABXGCsMjDn0VT0DmP6qeuiytce9cNBx8PywpqejiFNVhwd0UGg@mail.gmail.com> <ee245af2-a0ae-5c13-6f1f-2418f43d1812@suse.cz>
In-Reply-To: <ee245af2-a0ae-5c13-6f1f-2418f43d1812@suse.cz>
From: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Date: Mon, 1 Jul 2019 02:15:06 +0500
Message-ID: <CABXGCsOpj_E7jL9OpMX4wZbMktiF=9WOyeTv1R-W59gFMGC7mw@mail.gmail.com>
Subject: Re: kernel BUG at mm/swap_state.c:170!
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@kernel.org>, 
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, 
	Matthew Wilcox <willy@infradead.org>, Qian Cai <cai@lca.pw>, Jan Kara <jack@suse.cz>, 
	kirill.shutemov@linux.intel.com, songliubraving@fb.com, 
	william.kucharski@oracle.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 17 Jun 2019 at 17:17, Vlastimil Babka <vbabka@suse.cz> wrote:
>
>
> You told bisect that 5.2-rc1 is good, but it probably isn't.
> What you probably need to do is:
> git bisect good v5.1
> git bisect bad v5.2-rc2
>

$ git bisect log
git bisect start
# good: [e93c9c99a629c61837d5a7fc2120cd2b6c70dbdd] Linux 5.1
git bisect good e93c9c99a629c61837d5a7fc2120cd2b6c70dbdd
# bad: [cd6c84d8f0cdc911df435bb075ba22ce3c605b07] Linux 5.2-rc2
git bisect bad cd6c84d8f0cdc911df435bb075ba22ce3c605b07
# good: [f4d9a23d3dad0252f375901bf4ff6523a2c97241] sparc64: simplify
reduce_memory() function
git bisect good f4d9a23d3dad0252f375901bf4ff6523a2c97241
# good: [4dbf09fea60d158e60a30c419e0cfa1ea138dd57] Merge tag
'mtd/for-5.2' of
ssh://gitolite.kernel.org/pub/scm/linux/kernel/git/mtd/linux
git bisect good 4dbf09fea60d158e60a30c419e0cfa1ea138dd57
# bad: [22c58fd70ca48a29505922b1563826593b08cc00] Merge tag
'armsoc-soc' of git://git.kernel.org/pub/scm/linux/kernel/git/soc/soc
git bisect bad 22c58fd70ca48a29505922b1563826593b08cc00
# skip: [414147d99b928c574ed76e9374a5d2cb77866a29] Merge tag
'pci-v5.2-changes' of
git://git.kernel.org/pub/scm/linux/kernel/git/helgaas/pci
git bisect skip 414147d99b928c574ed76e9374a5d2cb77866a29
# bad: [841964e86acf48317db0469daf821e44554d8b0c] autofs: update mount
control expire desription with AUTOFS_EXP_FORCED
git bisect bad 841964e86acf48317db0469daf821e44554d8b0c
# good: [7e9890a3500d95c01511a4c45b7e7192dfa47ae2] Merge tag
'ovl-update-5.2' of
git://git.kernel.org/pub/scm/linux/kernel/git/mszeredi/vfs
git bisect good 7e9890a3500d95c01511a4c45b7e7192dfa47ae2
# good: [c7a1c2bbb65e25551d585fba0fd36a01e0a22690] Merge branch 'pci/trivial'
git bisect good c7a1c2bbb65e25551d585fba0fd36a01e0a22690
# good: [9dc2108d667da44c7b147b185b64e31c0a60f583] ocfs2: use common
file type conversion
git bisect good 9dc2108d667da44c7b147b185b64e31c0a60f583
# bad: [ef4d6f6b275c498f8e5626c99dbeefdc5027f843]
include/linux/bitops.h: sanitize rotate primitives
git bisect bad ef4d6f6b275c498f8e5626c99dbeefdc5027f843
# bad: [19343b5bdd16ad4ae6b845ef829f68b683c4dfb5] mm/page-writeback:
introduce tracepoint for wait_on_page_writeback()
git bisect bad 19343b5bdd16ad4ae6b845ef829f68b683c4dfb5
# bad: [2d0adf7e0d7ac1e18da874c5b19ef30a0db59658] mm/hugetlb: get rid
of NODEMASK_ALLOC
git bisect bad 2d0adf7e0d7ac1e18da874c5b19ef30a0db59658
# skip: [2b59e01a3aa665f751d1410b99fae9336bd424e1] mm/cma.c: fix the
bitmap status to show failed allocation reason
git bisect skip 2b59e01a3aa665f751d1410b99fae9336bd424e1
# good: [916ac0527837aa0be46d82804f93dd46f03aaedc] slub: use slab_list
instead of lru
git bisect good 916ac0527837aa0be46d82804f93dd46f03aaedc
# skip: [5e65af19e89ac33dc83e1869c78b33ed7099469b]
mm/page_isolation.c: remove redundant pfn_valid_within() in
__first_valid_page()
git bisect skip 5e65af19e89ac33dc83e1869c78b33ed7099469b
# skip: [2b487e59f00aaa885ebf9c47d44d09f3ef4df80e] mm: memcontrol:
push down mem_cgroup_node_nr_lru_pages()
git bisect skip 2b487e59f00aaa885ebf9c47d44d09f3ef4df80e
# bad: [a861bbce27634160ae0330126b4ef001d6941c8f] sh: advertise
gigantic page support
git bisect bad a861bbce27634160ae0330126b4ef001d6941c8f
# skip: [d3ba3ae19751e476b0840a0c9a673a5766fa3219]
mm/memory_hotplug.c: fix the wrong usage of N_HIGH_MEMORY
git bisect skip d3ba3ae19751e476b0840a0c9a673a5766fa3219
# bad: [54c7a8916a887f357088f99e9c3a7720cd57d2c8] initramfs: free
initrd memory if opening /initrd.image fails
git bisect bad 54c7a8916a887f357088f99e9c3a7720cd57d2c8
# skip: [7af75561e17132b20b5bc047d222f34b3e7a3e6e] mm/gup: add
FOLL_LONGTERM capability to GUP fast
git bisect skip 7af75561e17132b20b5bc047d222f34b3e7a3e6e
# skip: [9851ac13592df77958ae7bac6ba39e71420c38ec] mm: move
nr_deactivate accounting to shrink_active_list()
git bisect skip 9851ac13592df77958ae7bac6ba39e71420c38ec
# good: [16cb0ec75b346ec4fce11c5ce40d68b173f4e2f4] slab: use slab_list
instead of lru
git bisect good 16cb0ec75b346ec4fce11c5ce40d68b173f4e2f4
# skip: [9fdf4aa156733e3f075a9d7d0b026648b3874afe] IB/hfi1: use the
new FOLL_LONGTERM flag to get_user_pages_fast()
git bisect skip 9fdf4aa156733e3f075a9d7d0b026648b3874afe
# bad: [113b7dfd827175977ea71cc4a29c1ac24acb9fce] mm: memcontrol:
quarantine the mem_cgroup_[node_]nr_lru_pages() API
git bisect bad 113b7dfd827175977ea71cc4a29c1ac24acb9fce
# good: [517f9f1ee5ed0a05d0f6f884f6d9b5c46ac5a810] mm/slab.c: remove
unneed check in cpuup_canceled
git bisect good 517f9f1ee5ed0a05d0f6f884f6d9b5c46ac5a810
# bad: [664b21e717cfe4781137263f2555da335549210e] IB/qib: use the new
FOLL_LONGTERM flag to get_user_pages_fast()
git bisect bad 664b21e717cfe4781137263f2555da335549210e
# skip: [886cf1901db962cee5f8b82b9b260079a5e8a4eb] mm: move
recent_rotated pages calculation to shrink_inactive_list()
git bisect skip 886cf1901db962cee5f8b82b9b260079a5e8a4eb
# skip: [b798bec4741bdd80224214fdd004c8e52698e425] mm/gup: change
write parameter to flags in fast walk
git bisect skip b798bec4741bdd80224214fdd004c8e52698e425
# skip: [63931eb97508cd67515dbcc049defaebd7b1fcd0] mm, page_alloc:
disallow __GFP_COMP in alloc_pages_exact()
git bisect skip 63931eb97508cd67515dbcc049defaebd7b1fcd0
# good: [f0fd50504a54f5548eb666dc16ddf8394e44e4b7] mm/cma_debug.c: fix
the break condition in cma_maxchunk_get()
git bisect good f0fd50504a54f5548eb666dc16ddf8394e44e4b7
# skip: [a222f341586834073c2bbea225be38216eb5d993] mm: generalize
putback scan functions
git bisect skip a222f341586834073c2bbea225be38216eb5d993
# bad: [f372d89e5dbbf2bc8e37089bacd526afd4e1d6c2] mm: remove
pages_to_free argument of move_active_pages_to_lru()
git bisect bad f372d89e5dbbf2bc8e37089bacd526afd4e1d6c2
# bad: [5fd4ca2d84b249f0858ce28cf637cf25b61a398f] mm: page cache:
store only head pages in i_pages
git bisect bad 5fd4ca2d84b249f0858ce28cf637cf25b61a398f
# good: [cefdca0a86be517bc390fc4541e3674b8e7803b0] userfaultfd/sysctl:
add vm.unprivileged_userfaultfd
git bisect good cefdca0a86be517bc390fc4541e3674b8e7803b0
# first bad commit: [5fd4ca2d84b249f0858ce28cf637cf25b61a398f] mm:
page cache: store only head pages in i_pages

All kernel logs uploaded here:
https://mega.nz/#F!00wFHACA!nmaLgkkbrlt46DteERjl7Q

> The VM_BUG_ON_PAGE has been touched in 5.2-rc1 by commit
> 5fd4ca2d84b2 ("mm: page cache: store only head pages in i_pages")
> CCing relevant people and keeping rest of mail for reference.

Yes, this is exactly right commit.
But when I did bisect I am found yet another problem.
When hit memory limit and starting paging the virtual machine in KVM is hanged.
If after it I reboot computer then the system will completely hang.
All this commits I marked as skip in my bisecting.
And the backtrace in kernel log looks like as below:

[ 5729.146324] sysrq: Show Blocked State
[ 5729.151171]   task                        PC stack   pid father
[ 5729.156081] khugepaged      D    0    98      2 0x80004000
[ 5729.160941] Call Trace:
[ 5729.165803]  ? __schedule+0x29f/0x680
[ 5729.170669]  schedule+0x33/0x90
[ 5729.175543]  __rwsem_down_write_failed_common+0x1a6/0x470
[ 5729.180424]  down_write+0x39/0x40
[ 5729.185301]  khugepaged+0xe46/0x2380
[ 5729.190179]  ? syscall_return_via_sysret+0x10/0x7f
[ 5729.195069]  ? __switch_to_asm+0x34/0x70
[ 5729.199951]  ? __switch_to_asm+0x40/0x70
[ 5729.204825]  ? __switch_to_asm+0x34/0x70
[ 5729.209692]  ? __switch_to_asm+0x40/0x70
[ 5729.214553]  ? __switch_to_asm+0x34/0x70
[ 5729.219407]  ? finish_wait+0x80/0x80
[ 5729.224261]  kthread+0xfb/0x130
[ 5729.229115]  ? collapse_shmem+0xe00/0xe00
[ 5729.233968]  ? kthread_park+0x90/0x90
[ 5729.238823]  ret_from_fork+0x22/0x40
[ 5729.243784] umount          D    0 30362      1 0x00004004
[ 5729.248649] Call Trace:
[ 5729.253499]  ? __schedule+0x29f/0x680
[ 5729.258354]  ? account_entity_enqueue+0xc5/0xf0
[ 5729.263217]  schedule+0x33/0x90
[ 5729.268072]  schedule_timeout+0x209/0x300
[ 5729.272930]  wait_for_completion+0x10d/0x160
[ 5729.277796]  ? wake_up_q+0x60/0x60
[ 5729.282654]  __flush_work+0x11f/0x1d0
[ 5729.287512]  ? worker_attach_to_pool+0x90/0x90
[ 5729.292378]  lru_add_drain_all+0x106/0x140
[ 5729.297240]  invalidate_bdev+0x3c/0x50
[ 5729.302100]  ext4_put_super+0x1e6/0x380
[ 5729.306961]  generic_shutdown_super+0x6c/0x100
[ 5729.311809]  kill_block_super+0x21/0x50
[ 5729.316648]  deactivate_locked_super+0x36/0x70
[ 5729.321491]  cleanup_mnt+0x3b/0x80
[ 5729.326325]  task_work_run+0x87/0xa0
[ 5729.331156]  exit_to_usermode_loop+0xc2/0xd0
[ 5729.335993]  do_syscall_64+0x14f/0x170
[ 5729.340815]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
[ 5729.345646] RIP: 0033:0x7f996dde665b
[ 5729.350477] Code: Bad RIP value.
[ 5729.355304] RSP: 002b:00007ffe57829d78 EFLAGS: 00000246 ORIG_RAX:
00000000000000a6
[ 5729.360166] RAX: 0000000000000000 RBX: 00007f996df0f1e4 RCX: 00007f996dde665b
[ 5729.365032] RDX: ffffffffffffff78 RSI: 0000000000000000 RDI: 00005618b787c380
[ 5729.369903] RBP: 00005618b787b460 R08: 0000000000000000 R09: 00007ffe57828af0
[ 5729.374781] R10: 00007f996de6bc40 R11: 0000000000000246 R12: 00005618b787c380
[ 5729.379657] R13: 0000000000000000 R14: 00005618b787b558 R15: 00005618b787b670
[ 5729.384535] swapoff         D    0 30364      1 0x00004004
[ 5729.389419] Call Trace:
[ 5729.394285]  ? __schedule+0x29f/0x680
[ 5729.399136]  schedule+0x33/0x90
[ 5729.403982]  rwsem_down_read_failed+0x12a/0x1c0
[ 5729.408835]  try_to_unuse+0x116/0x6c0
[ 5729.413684]  __do_sys_swapoff+0x1d0/0x660
[ 5729.418535]  do_syscall_64+0x5b/0x170
[ 5729.423380]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
[ 5729.428222] RIP: 0033:0x7f390519464b
[ 5729.433158] Code: Bad RIP value.
[ 5729.437869] RSP: 002b:00007ffd7fa96f08 EFLAGS: 00000206 ORIG_RAX:
00000000000000a8
[ 5729.442604] RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 00007f390519464b
[ 5729.447336] RDX: 0000000000000001 RSI: 0000000000000000 RDI: 0000562ba52ef4a0
[ 5729.452069] RBP: 00007ffd7fa97f23 R08: 0000562ba52f04f0 R09: 0000000000000060
[ 5729.456745] R10: 0000000000000000 R11: 0000000000000206 R12: 0000000000000000
[ 5729.461356] R13: 0000562ba52ef4a0 R14: 0000000000000000 R15: 0000000000000000
[ 7016.819033] sysrq: Kill All Tasks
[ 7016.825376] kauditd_printk_skb: 1 callbacks suppressed
[ 7016.825377] audit: type=1131 audit(1561806917.764:517): pid=1 uid=0
auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0
msg='unit=systemd-journald comm="systemd"
exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=?
res=failed'
[ 7016.835240] systemd[1]: systemd-udevd.service: Main process exited,
code=killed, status=9/KILL
[ 7016.839643] systemd[1]: systemd-udevd.service: Failed with result 'signal'.
[ 7016.842886] audit: type=1131 audit(1561806917.781:518): pid=1 uid=0
auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0
msg='unit=systemd-udevd comm="systemd" exe="/usr/lib/systemd/systemd"
hostname=? addr=? terminal=? res=failed'
[ 7016.842925] systemd[1]: systemd-journald.service: Service has no
hold-off time (RestartSec=0), scheduling restart.
[ 7016.848111] systemd[1]: systemd-journald.service: Scheduled restart
job, restart counter is at 4.
[ 7016.850579] systemd[1]: systemd-udevd.service: Service has no
hold-off time (RestartSec=0), scheduling restart.
[ 7016.853030] systemd[1]: systemd-udevd.service: Scheduled restart
job, restart counter is at 3.
[ 7016.855447] systemd[1]: Stopped udev Kernel Device Manager.
[ 7016.858073] audit: type=1130 audit(1561806917.797:519): pid=1 uid=0
auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0
msg='unit=systemd-udevd comm="systemd" exe="/usr/lib/systemd/systemd"
hostname=? addr=? terminal=? res=success'
[ 7016.862154] audit: type=1131 audit(1561806917.797:520): pid=1 uid=0
auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0
msg='unit=systemd-udevd comm="systemd" exe="/usr/lib/systemd/systemd"
hostname=? addr=? terminal=? res=success'
[ 7016.867367] systemd[1]: Starting udev Kernel Device Manager...
[ 7016.872311] systemd[1]: systemd-journal-flush.service: Succeeded.
[ 7016.874695] systemd[1]: Stopped Flush Journal to Persistent Storage.
[ 7016.879546] audit: type=1131 audit(1561806917.818:521): pid=1 uid=0
auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0
msg='unit=systemd-journal-flush comm="systemd"
exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=?
res=success'
[ 7016.888393] audit: type=1130 audit(1561806917.827:522): pid=1 uid=0
auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0
msg='unit=systemd-journald comm="systemd"
exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=?
res=success'
[ 7016.893011] audit: type=1131 audit(1561806917.827:523): pid=1 uid=0
auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0
msg='unit=systemd-journald comm="systemd"
exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=?
res=success'
[ 7017.088027] audit: type=1130 audit(1561806918.027:524): pid=1 uid=0
auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0
msg='unit=systemd-udevd comm="systemd" exe="/usr/lib/systemd/systemd"
hostname=? addr=? terminal=? res=success'
[ 7017.105306] audit: type=1305 audit(1561806918.044:525): op=set
audit_enabled=1 old=1 auid=4294967295 ses=4294967295
subj=system_u:system_r:syslogd_t:s0 res=1
[ 7017.113711] audit: type=1130 audit(1561806918.052:526): pid=1 uid=0
auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0
msg='unit=systemd-journald comm="systemd"
exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=?
res=success'
[ 7026.699959] sysrq: Resetting
[ 7026.704037] ACPI MEMORY or I/O RESET_REG.

 The third problem I noticed a long time ago. Symptomes: applications
can use only half of the swap partition. I have a swap partition size
RAM * 2. The applications start crashing when the swap partition is
used more than half. And this is not OOM.
For example for testing each commit I completely filled  RAM, and
after sure that system is not hanged I launched compiling next bisect
iteration. And here happens crashes of gcc if swap is used over 32GB.
(Full swap size is 64GB)

>
> The presence of the other ext4 bug complicates the bisect, however.
> According to tytso in the thread you linked, it should be fixed by
> commit 0a944e8a6c66, while the bug was introduced by commit
> 345c0dbf3a30. So in each step of bisect, before building the kernel, you
> should cherry-pick the fix if the bug is there:
>
> git merge-base --is-ancestor 345c0dbf3a30 HEAD && git cherry-pick 0a944e8a6c66
>

Commands above lead to cyclic bisecting on one commit. So I used `git
stash` and `git stash pop` for applying ext4 patch.

--
Best Regards,
Mike Gavrilov.

