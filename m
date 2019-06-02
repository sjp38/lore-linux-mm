Return-Path: <SRS0=2YS/=UB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7FC87C282DC
	for <linux-mm@archiver.kernel.org>; Sun,  2 Jun 2019 19:56:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 21941279BD
	for <linux-mm@archiver.kernel.org>; Sun,  2 Jun 2019 19:56:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 21941279BD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=chris-wilson.co.uk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4783A6B000D; Sun,  2 Jun 2019 15:56:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 428E06B000E; Sun,  2 Jun 2019 15:56:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 33E0F6B0010; Sun,  2 Jun 2019 15:56:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id DA89A6B000D
	for <linux-mm@kvack.org>; Sun,  2 Jun 2019 15:56:12 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id s4so7360683wrn.1
        for <linux-mm@kvack.org>; Sun, 02 Jun 2019 12:56:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :content-transfer-encoding:to:from:in-reply-to:cc:references
         :message-id:user-agent:subject:date;
        bh=C/ViA1DCxObsnpesPCBtIeoSGh3Ml6uwS0euKMoYbw4=;
        b=sAoTN+eKakmWfK58IdxWWA91SyzWFMJk7bQdCtkxr7O7mUQL7VK5KARYobWjtcNYDA
         55iKjrvQ9V8hSF6IjucLkFEz92wu/oAYU5DYQCp+gYRcBzfxNQ1Juai0Pig+AAd7YUqi
         uRd66xAtYM/XinZBwozWO46QbdmBY4sxQV/rm4B2kCUYZMfbhKMIJVBnj3oA3e2+GKZg
         53jajcg+IhT0SZhw+B15iEOfTGmMzOHN+i/wGf2iEYwFiFuEExSc6Uz3INkccdrVBo6A
         7a2gTHxy6poFZlhdEHjmezmdpwJ4lCMbvmcU6QELfejIWbrrUSeTu9mQoKOSD4lznevQ
         E/nA==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 109.228.58.192 is neither permitted nor denied by best guess record for domain of chris@chris-wilson.co.uk) smtp.mailfrom=chris@chris-wilson.co.uk
X-Gm-Message-State: APjAAAXf7tLt7LHmdOgDrfFY8dkc1PR6LYp4b/YpN8mZBwoLCR221hI9
	nLt7E/N427B2b/lLjFF3xff8D7A5o5IkwM806OSVDKZIin0ThUIrbXvOgG1Nn/CgOKZPlKMxeKm
	POoBT+gdHjNLirLHcqReSy297D07PfZDklL8akq+CAn4e7yWCrud3bVjRE4C6SQo=
X-Received: by 2002:a1c:407:: with SMTP id 7mr1675wme.113.1559505372086;
        Sun, 02 Jun 2019 12:56:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyIA9p1En0YwLHFcJcERQ8mdxm+RGzG+RIflD+nq87eioNpn58cljFw7sNhpqPEaCGfVfyd
X-Received: by 2002:a1c:407:: with SMTP id 7mr12492598wme.113.1559503737662;
        Sun, 02 Jun 2019 12:28:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559503737; cv=none;
        d=google.com; s=arc-20160816;
        b=cb1puadaL6iSIEZSXSRXFcVXAUhoqryoyZTG1N8FF7mYAHMakWff44lNUEuD6JahtR
         OXNYurZ2OtzkvI+kQotm1W1nO5Yfw05wFrKeEM3eV+TbXKqwp54EBrFfvZeFi0gjFeCM
         AlzdTl/aS2+pM50iEq7j/ekcLmMj/TpWwqIttUEzvSMj/ujrg09jhWVZmtyaEGibcfSA
         NMXIm0ZgrZQWOQlfhWii1KxLQGJAq0XRYOCbdzOeWct4zk0CvsCenXElBOFMyPxeF0TP
         Lsa/rKUAO6M3EhEThFuh5AadqDr4+aCSzB6zqaU1IfxIO9vgWRR5ShxVmiFC+RHjL4hY
         SKOA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:subject:user-agent:message-id:references:cc:in-reply-to:from
         :to:content-transfer-encoding:mime-version;
        bh=C/ViA1DCxObsnpesPCBtIeoSGh3Ml6uwS0euKMoYbw4=;
        b=ogWBNgFFbIxC3M3l7Y4gmVzXf+RpHmGvgSU+OfZkG4ar3y5erCf95YdvZXSY3qz//9
         M0AzaOl1BXtNLBaFhXgiU5j3BVXRpv/XKj0H/hiTn7tmkXvt9F7mavTx9DAlr9Fpzuvv
         u0x+6HCJ6RASPYlUEhe0HuDrvDenBNY8Vp7lfnfSBwNkGnCj70MLxQ/TWzZhIGGjmIZn
         Rggp8dV/spwRWmtOuLRA4NAOG1sqZz79TOMoW7YMoGf21GHRhA9JnTh7NyGX2Uw2DVEo
         aXKvKRH9gIov3V87iGptNsdmMQzGZrqVO2Ixw3EUY+MsMpd1iS/gT0TwPbVQBlTkMRif
         KOlw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 109.228.58.192 is neither permitted nor denied by best guess record for domain of chris@chris-wilson.co.uk) smtp.mailfrom=chris@chris-wilson.co.uk
Received: from fireflyinternet.com (mail.fireflyinternet.com. [109.228.58.192])
        by mx.google.com with ESMTPS id p14si9496546wrw.234.2019.06.02.12.28.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 02 Jun 2019 12:28:57 -0700 (PDT)
Received-SPF: neutral (google.com: 109.228.58.192 is neither permitted nor denied by best guess record for domain of chris@chris-wilson.co.uk) client-ip=109.228.58.192;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 109.228.58.192 is neither permitted nor denied by best guess record for domain of chris@chris-wilson.co.uk) smtp.mailfrom=chris@chris-wilson.co.uk
X-Default-Received-SPF: pass (skip=forwardok (res=PASS)) x-ip-name=78.156.65.138;
Received: from localhost (unverified [78.156.65.138]) 
	by fireflyinternet.com (Firefly Internet (M1)) with ESMTP (TLS) id 16768014-1500050 
	for multiple; Sun, 02 Jun 2019 20:28:09 +0100
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
To: Matthew Wilcox <willy@infradead.org>
From: Chris Wilson <chris@chris-wilson.co.uk>
In-Reply-To: <20190602105150.GB23346@bombadil.infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 "Kirill A. Shutemov" <kirill@shutemov.name>, Hugh Dickins <hughd@google.com>,
 Jan Kara <jack@suse.cz>, Song Liu <liu.song.a23@gmail.com>
References: <20190307153051.18815-1-willy@infradead.org>
 <155938118174.22493.11599751119608173366@skylake-alporthouse-com>
 <155938946857.22493.6955534794168533151@skylake-alporthouse-com>
 <20190602105150.GB23346@bombadil.infradead.org>
Message-ID: <155950368509.22493.15394943722747213271@skylake-alporthouse-com>
User-Agent: alot/0.6
Subject: Re: [PATCH v4] page cache: Store only head pages in i_pages
Date: Sun, 02 Jun 2019 20:28:05 +0100
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Quoting Matthew Wilcox (2019-06-02 11:51:50)
> On Sat, Jun 01, 2019 at 12:44:28PM +0100, Chris Wilson wrote:
> > Quoting Chris Wilson (2019-06-01 10:26:21)
> > > Quoting Matthew Wilcox (2019-03-07 15:30:51)
> > > > Transparent Huge Pages are currently stored in i_pages as pointers =
to
> > > > consecutive subpages.  This patch changes that to storing consecuti=
ve
> > > > pointers to the head page in preparation for storing huge pages more
> > > > efficiently in i_pages.
> > > > =

> > > > Large parts of this are "inspired" by Kirill's patch
> > > > https://lore.kernel.org/lkml/20170126115819.58875-2-kirill.shutemov=
@linux.intel.com/
> > > > =

> > > > Signed-off-by: Matthew Wilcox <willy@infradead.org>
> > > > Acked-by: Jan Kara <jack@suse.cz>
> > > > Reviewed-by: Kirill Shutemov <kirill@shutemov.name>
> > > > Reviewed-and-tested-by: Song Liu <songliubraving@fb.com>
> > > > Tested-by: William Kucharski <william.kucharski@oracle.com>
> > > > Reviewed-by: William Kucharski <william.kucharski@oracle.com>
> > > =

> > > I've bisected some new softlockups under THP mempressure to this patc=
h.
> > > They are all rcu stalls that look similar to:
> > > [  242.645276] rcu: INFO: rcu_preempt detected stalls on CPUs/tasks:
> > > [  242.645293] rcu:     Tasks blocked on level-0 rcu_node (CPUs 0-3):=
 P828
> > > [  242.645301]  (detected by 1, t=3D5252 jiffies, g=3D55501, q=3D221)
> > > [  242.645307] gem_syslatency  R  running task        0   828    815 =
0x00004000
> > > [  242.645315] Call Trace:
> > > [  242.645326]  ? __schedule+0x1a0/0x440
> > > [  242.645332]  ? preempt_schedule_irq+0x27/0x50
> > > [  242.645337]  ? apic_timer_interrupt+0xa/0x20
> > > [  242.645342]  ? xas_load+0x3c/0x80
> > > [  242.645347]  ? xas_load+0x8/0x80
> > > [  242.645353]  ? find_get_entry+0x4f/0x130
> > > [  242.645358]  ? pagecache_get_page+0x2b/0x210
> > > [  242.645364]  ? lookup_swap_cache+0x42/0x100
> > > [  242.645371]  ? do_swap_page+0x6f/0x600
> > > [  242.645375]  ? unmap_region+0xc2/0xe0
> > > [  242.645380]  ? __handle_mm_fault+0x7a9/0xfa0
> > > [  242.645385]  ? handle_mm_fault+0xc2/0x1c0
> > > [  242.645393]  ? __do_page_fault+0x198/0x410
> > > [  242.645399]  ? page_fault+0x5/0x20
> > > [  242.645404]  ? page_fault+0x1b/0x20
> > > =

> > > Any suggestions as to what information you might want?
> > =

> > Perhaps,
> > [   76.175502] page:ffffea00098e0000 count:0 mapcount:0 mapping:0000000=
000000000 index:0x1
> > [   76.175525] flags: 0x8000000000000000()
> > [   76.175533] raw: 8000000000000000 ffffea0004a7e988 ffffea000445c3c8 =
0000000000000000
> > [   76.175538] raw: 0000000000000001 0000000000000000 00000000ffffffff =
0000000000000000
> > [   76.175543] page dumped because: VM_BUG_ON_PAGE(entry !=3D page)
> > [   76.175560] ------------[ cut here ]------------
> > [   76.175564] kernel BUG at mm/swap_state.c:170!
> > [   76.175574] invalid opcode: 0000 [#1] PREEMPT SMP
> > [   76.175581] CPU: 0 PID: 131 Comm: kswapd0 Tainted: G     U          =
  5.1.0+ #247
> > [   76.175586] Hardware name:  /NUC6CAYB, BIOS AYAPLCEL.86A.0029.2016.1=
124.1625 11/24/2016
> > [   76.175598] RIP: 0010:__delete_from_swap_cache+0x22e/0x340
> > [   76.175604] Code: e8 b7 3e fd ff 48 01 1d a8 7e 04 01 48 83 c4 30 5b=
 5d 41 5c 41 5d 41 5e 41 5f c3 48 c7 c6 03 7e bf 81 48 89 c7 e8 92 f8 fd ff=
 <0f> 0b 48 c7 c6 c8 7c bf 81 48 89 df e8 81 f8 fd ff 0f 0b 48 c7 c6
> > [   76.175613] RSP: 0000:ffffc900008dba88 EFLAGS: 00010046
> > [   76.175619] RAX: 0000000000000032 RBX: ffffea00098e0040 RCX: 0000000=
000000006
> > [   76.175624] RDX: 0000000000000007 RSI: 0000000000000000 RDI: fffffff=
f81bf6d4c
> > [   76.175629] RBP: ffff888265ed8640 R08: 00000000000002c2 R09: 0000000=
000000000
> > [   76.175634] R10: 0000000273a4626d R11: 0000000000000000 R12: 0000000=
000000001
> > [   76.175639] R13: 0000000000000040 R14: 0000000000000000 R15: ffffea0=
0098e0000
> > [   76.175645] FS:  0000000000000000(0000) GS:ffff888277a00000(0000) kn=
lGS:0000000000000000
> > [   76.175651] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > [   76.175656] CR2: 00007f24e4399000 CR3: 0000000002c09000 CR4: 0000000=
0001406f0
> > [   76.175661] Call Trace:
> > [   76.175671]  __remove_mapping+0x1c2/0x380
> > [   76.175678]  shrink_page_list+0x11db/0x1d10
> > [   76.175684]  shrink_inactive_list+0x14b/0x420
> > [   76.175690]  shrink_node_memcg+0x20e/0x740
> > [   76.175696]  shrink_node+0xba/0x420
> > [   76.175702]  balance_pgdat+0x27d/0x4d0
> > [   76.175709]  kswapd+0x216/0x300
> > [   76.175715]  ? wait_woken+0x80/0x80
> > [   76.175721]  ? balance_pgdat+0x4d0/0x4d0
> > [   76.175726]  kthread+0x106/0x120
> > [   76.175732]  ? kthread_create_on_node+0x40/0x40
> > [   76.175739]  ret_from_fork+0x1f/0x30
> > [   76.175745] Modules linked in: i915 intel_gtt drm_kms_helper
> > [   76.175754] ---[ end trace 8faf2ec849d50724 ]---
> > [   76.206689] RIP: 0010:__delete_from_swap_cache+0x22e/0x340
> > [   76.206708] Code: e8 b7 3e fd ff 48 01 1d a8 7e 04 01 48 83 c4 30 5b=
 5d 41 5c 41 5d 41 5e 41 5f c3 48 c7 c6 03 7e bf 81 48 89 c7 e8 92 f8 fd ff=
 <0f> 0b 48 c7 c6 c8 7c bf 81 48 89 df e8 81 f8 fd ff 0f 0b 48 c7 c6
> > [   76.206718] RSP: 0000:ffffc900008dba88 EFLAGS: 00010046
> > [   76.206723] RAX: 0000000000000032 RBX: ffffea00098e0040 RCX: 0000000=
000000006
> > [   76.206729] RDX: 0000000000000007 RSI: 0000000000000000 RDI: fffffff=
f81bf6d4c
> > [   76.206734] RBP: ffff888265ed8640 R08: 00000000000002c2 R09: 0000000=
000000000
> > [   76.206740] R10: 0000000273a4626d R11: 0000000000000000 R12: 0000000=
000000001
> > [   76.206745] R13: 0000000000000040 R14: 0000000000000000 R15: ffffea0=
0098e0000
> > [   76.206750] FS:  0000000000000000(0000) GS:ffff888277a00000(0000) kn=
lGS:0000000000000000
> > [   76.206757] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> =

> Thanks for the reports, Chris.
> =

> I think they're both canaries; somehow the page cache / swap cache has
> got corrupted and contains entries that it shouldn't.
> =

> This second one (with the VM_BUG_ON_PAGE in __delete_from_swap_cache)
> shows a regular (non-huge) page at index 1.  There are two ways we might
> have got there; one is that we asked to delete a page at index 1 which is
> no longer in the cache.  The other is that we asked to delete a huge page
> at index 0, but the page wasn't subsequently stored in indices 1-511.
> =

> We dump the page that we found; not the page we're looking for, so I don't
> know which.  If this one's easy to reproduce, you could add:
> =

>         for (i =3D 0; i < nr; i++) {
>                 void *entry =3D xas_store(&xas, NULL);
> +               if (entry !=3D page) {
> +                       printk("Oh dear %d %d\n", i, nr);
> +                       dump_page(page, "deleting page");
> +               }
>                 VM_BUG_ON_PAGE(entry !=3D page, entry);
>                 set_page_private(page + i, 0);
>                 xas_next(&xas);
>         }
> =

> I'll re-read the patch and see if I can figure out how the cache is getti=
ng
> screwed up.  Given what you said, probably on the swap-in path.

I can give you a clue, it requires split_huge_page_to_list().
-Chris

