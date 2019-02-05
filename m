Return-Path: <SRS0=TNGr=QM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DF677C282CB
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 15:40:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 89C5F20844
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 15:40:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="SDTx12Fq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 89C5F20844
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 16A658E008E; Tue,  5 Feb 2019 10:40:25 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1192A8E001C; Tue,  5 Feb 2019 10:40:25 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F22148E008E; Tue,  5 Feb 2019 10:40:24 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id D217F8E001C
	for <linux-mm@kvack.org>; Tue,  5 Feb 2019 10:40:24 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id n22so3230315otq.8
        for <linux-mm@kvack.org>; Tue, 05 Feb 2019 07:40:24 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=xMf9sCWcBidB1KrzMHsGwrM00RACWGR46CjJlvkrpJ0=;
        b=KCm9JtrdB09Bd9fiHxenSVOx66ZQP7Qv9RAz6MseREWeR9aZ6K+iTqS6M0+W2nU3Tn
         hyDAQttYfCn/OcnKV47MgMkq8M7FS3r1AiJfU4ZTzWBheaGrnFlLBwLl4kqXOIsDQDIV
         NAVwSVB3M6VLN3pG2+uLlhwe0MR/iF1ly0ZZxj4ad5jQMelMsrBan5mIp2LErRESrhi0
         0wmuMpZG13I1F8wy77SlicmKljEaFrNTAysjHtEnISGOZT18YtVcwzAtYeTF0WWjqhTb
         ot+D/vrw43GQXkPZFa376smFHlcbmf/IgtWD62PQdwUB4H41VnNhyTpjNsIjFH5q1CRX
         XqcA==
X-Gm-Message-State: AHQUAuaFe1g40oOnus4ibe6paoNKiw1ugWmUJkl551p/ho3I8C4kumjK
	1N/vayl3Z510MmzSLV2Ud3WbIdzojgEDhpAMxIQp6i/bbYQJPcO+buTTWsDFf+3UfG5EWl+nXaP
	k4D8it4g1If/XdueBq+u890Ne6GHIJtb7L7DnBIiUziLJYN5BuI18qeMNUBVVGPu9mxRIPqzZzF
	/FCxUMNUt8tE36rybCDRwELUwkLfhFaA7/iBP5bRfr5oUIuMLV4OJRE7MB7Qb5IKKGjgDZQuioy
	uQ3NBVx7VPO7by6dsHb5Tks4ZF8oKeyE9t0Ht7R95ruLnUFFR5OZvQDSkgLNFWlH9KMBj1CFVO1
	u0HL+nc/55wEPzGvYd7I2B/z5n45bCUBwRba6RgOGkO1o/0XPE5ZuGCGehj73eT7IFRZ4fOL2T+
	o
X-Received: by 2002:a54:460a:: with SMTP id p10mr2726753oip.27.1549381224495;
        Tue, 05 Feb 2019 07:40:24 -0800 (PST)
X-Received: by 2002:a54:460a:: with SMTP id p10mr2726714oip.27.1549381223410;
        Tue, 05 Feb 2019 07:40:23 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549381223; cv=none;
        d=google.com; s=arc-20160816;
        b=z/92O3JgUNxlkwLxBKs0NQKHvuP+Cp5D9cOepWCugN4NaHM2jKXlzYlihpuy3HHhju
         AmZ0Xb8jlrt+isgkliHP43nMdpA94AfcaPPSURufAYoS50jMzdl71kKNxPRPvmJxhTbz
         QmRJ4DjRZ5tQ3dZPMtJeRZf84KrlIEz1LA4shxsmUYmWww+ytQchMDyGDrFwbM4BGmrK
         Fex7zvrNlj1kYj20eEa5gpRUkYjrQyDq/x3O6tHkxXkxH2C2Tnxp9I8zKRMD1DOsuWix
         p93AXRmjHPUKjciNdftLOqdPme2MXgrI0dXYko+qh1mLDtWBdt1tW/6XuBzu01djKXAE
         bgcw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=xMf9sCWcBidB1KrzMHsGwrM00RACWGR46CjJlvkrpJ0=;
        b=gPWDeLz9PnZPyqBhypT1/GzK3FptATi3QYPsPaOwg/916Py3Jp0JfVT55npTXavkFc
         x5/w+x+hTmEi0wzIyLxWoO/5EUFg0EIJZk3EUgi2DA4SR6FZyFefM/DcfU0V1s47kwxA
         nApmgOMzeW6WBSs7mAWN9BwthygOrTkRMlY2w2nUifqqtf71Y5rm+QrEQf+bSBdgQWYS
         PL9Lc30zPIQThwSunEjZ4SZBEa87SWV7ZgZ2Di2SgoB1Eo4oS7mW7AqGkZY0EPmO7XLU
         7Xxdm/TDDvvdm2MD6F55MxONb1XkzoHgvTxtBuVn5Npj9+L4LUM5mTixMnIbSY6xgffY
         G7Xg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=SDTx12Fq;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a74sor11688572oib.74.2019.02.05.07.40.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 05 Feb 2019 07:40:23 -0800 (PST)
Received-SPF: pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=SDTx12Fq;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=xMf9sCWcBidB1KrzMHsGwrM00RACWGR46CjJlvkrpJ0=;
        b=SDTx12FqXxcySow8kMzoghI35nP5LBHgbn/HbijJO+w0aAEQ4Kn+UFISdfTKCxJqDT
         GXivhDDSJayexsN8X8nnZKRBXrNdeFdP1WBN7FuxrJ7CQ8ZTOJbvMdxFhRU1hs2pUaSA
         Dpm98Am395kIY+NCiSrY8ELzTNPWWRhIQzZ0TtTMrkEKpCwVCKE3GlDu8Otcte0O7/de
         N2Lcnm/YWrCdNvc/72tBxY+ui2EuXhpRDpBdu3+KnNop7o7Yti96c7FfvfMYPv4lpIyH
         ML2I1pRO9XlT5QBQykB6c8Eid6/VXdweRza6/yPMboAgo0xVbyer5CzfYHl0RcVoRsk5
         2FGg==
X-Google-Smtp-Source: AHgI3IbWESCzz7A+auemd1v1x+8QwfOXCrpH+g59pkXhN2t0/QA1H81fxqyrTWgoKMVy3+exHg5YWQ==
X-Received: by 2002:aca:38c2:: with SMTP id f185mr3047574oia.26.1549381222379;
        Tue, 05 Feb 2019 07:40:22 -0800 (PST)
Received: from eggly.attlocal.net (172-10-233-147.lightspeed.sntcca.sbcglobal.net. [172.10.233.147])
        by smtp.gmail.com with ESMTPSA id a15sm8383456otd.66.2019.02.05.07.40.20
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 05 Feb 2019 07:40:21 -0800 (PST)
Date: Tue, 5 Feb 2019 07:40:11 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
X-X-Sender: hugh@eggly.anvils
To: Artem Savkov <asavkov@redhat.com>
cc: Hugh Dickins <hughd@google.com>, Baoquan He <bhe@redhat.com>, 
    Qian Cai <cai@lca.pw>, Andrea Arcangeli <aarcange@redhat.com>, 
    Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, 
    Linus Torvalds <torvalds@linux-foundation.org>, 
    Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, 
    linux-mm@kvack.org
Subject: Re: mm: race in put_and_wait_on_page_locked()
In-Reply-To: <20190205121002.GA32424@shodan.usersys.redhat.com>
Message-ID: <alpine.LSU.2.11.1902050725010.8467@eggly.anvils>
References: <20190204091300.GB13536@shodan.usersys.redhat.com> <alpine.LSU.2.11.1902041201280.4441@eggly.anvils> <20190205121002.GA32424@shodan.usersys.redhat.com>
User-Agent: Alpine 2.11 (LSU 23 2013-08-11)
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 5 Feb 2019, Artem Savkov wrote:
> On Mon, Feb 04, 2019 at 12:42:50PM -0800, Hugh Dickins wrote:
> > On Mon, 4 Feb 2019, Artem Savkov wrote:
> > 
> > > Hi Hugh,
> > > 
> > > Your recent patch 9a1ea439b16b "mm: put_and_wait_on_page_locked() while
> > > page is migrated" seems to have introduced a race into page migration
> > > process. I have a host that eagerly reproduces the following BUG under
> > > stress:
> > > 
> > > [  302.847402] page:f000000000021700 count:0 mapcount:0 mapping:c0000000b2710bb0 index:0x19
> > > [  302.848096] xfs_address_space_operations [xfs] 
> > > [  302.848100] name:"libc-2.28.so" 
> > > [  302.848244] flags: 0x3ffff800000006(referenced|uptodate)
> > > [  302.848521] raw: 003ffff800000006 5deadbeef0000100 5deadbeef0000200 0000000000000000
> > > [  302.848724] raw: 0000000000000019 0000000000000000 00000001ffffffff c0000000bc0b1000
> > > [  302.848919] page dumped because: VM_BUG_ON_PAGE(page_ref_count(page) == 0)
> > > [  302.849076] page->mem_cgroup:c0000000bc0b1000
> > > [  302.849269] ------------[ cut here ]------------
> > > [  302.849397] kernel BUG at include/linux/mm.h:546!
> > > [  302.849586] Oops: Exception in kernel mode, sig: 5 [#1]
> > > [  302.849711] LE SMP NR_CPUS=2048 NUMA pSeries
> > > [  302.849839] Modules linked in: pseries_rng sunrpc xts vmx_crypto virtio_balloon xfs libcrc32c virtio_net net_failover virtio_console failover virtio_blk
> > > [  302.850400] CPU: 3 PID: 8759 Comm: cc1 Not tainted 5.0.0-rc4+ #36
> > > [  302.850571] NIP:  c00000000039c8b8 LR: c00000000039c8b4 CTR: c00000000080a0e0
> > > [  302.850758] REGS: c0000000b0d7f7e0 TRAP: 0700   Not tainted  (5.0.0-rc4+)
> > > [  302.850952] MSR:  8000000000029033 <SF,EE,ME,IR,DR,RI,LE>  CR: 48024422  XER: 00000000
> > > [  302.851150] CFAR: c0000000003ff584 IRQMASK: 0 
> > > [  302.851150] GPR00: c00000000039c8b4 c0000000b0d7fa70 c000000001bcca00 0000000000000021 
> > > [  302.851150] GPR04: c0000000b044c628 0000000000000007 55555555555555a0 c000000001fc3760 
> > > [  302.851150] GPR08: 0000000000000007 0000000000000000 c0000000b0d7c000 c0000000b0d7f5ff 
> > > [  302.851150] GPR12: 0000000000004400 c00000003fffae80 0000000000000000 0000000000000000 
> > > [  302.851150] GPR16: 0000000000000000 0000000000000000 0000000000000000 0000000000000000 
> > > [  302.851150] GPR20: c0000000689f5aa8 c00000002a13ee48 0000000000000000 c000000001da29b0 
> > > [  302.851150] GPR24: c000000001bf7d80 c0000000689f5a00 0000000000000000 0000000000000000 
> > > [  302.851150] GPR28: c000000001bf9e80 c0000000b0d7fab8 0000000000000001 f000000000021700 
> > > [  302.852914] NIP [c00000000039c8b8] put_and_wait_on_page_locked+0x398/0x3d0
> > > [  302.853080] LR [c00000000039c8b4] put_and_wait_on_page_locked+0x394/0x3d0
> > > [  302.853235] Call Trace:
> > > [  302.853305] [c0000000b0d7fa70] [c00000000039c8b4] put_and_wait_on_page_locked+0x394/0x3d0 (unreliable)
> > > [  302.853540] [c0000000b0d7fb10] [c00000000047b838] __migration_entry_wait+0x178/0x250
> > > [  302.853738] [c0000000b0d7fb50] [c00000000040c928] do_swap_page+0xd78/0xf60
> > > [  302.853997] [c0000000b0d7fbd0] [c000000000411078] __handle_mm_fault+0xbf8/0xe80
> > > [  302.854187] [c0000000b0d7fcb0] [c000000000411548] handle_mm_fault+0x248/0x450
> > > [  302.854379] [c0000000b0d7fd00] [c000000000078ca4] __do_page_fault+0x2d4/0xdf0
> > > [  302.854877] [c0000000b0d7fde0] [c0000000000797f8] do_page_fault+0x38/0xf0
> > > [  302.855057] [c0000000b0d7fe20] [c00000000000a7c4] handle_page_fault+0x18/0x38
> > > [  302.855300] Instruction dump:
> > > [  302.855432] 4bfffcf0 60000000 3948ffff 4bfffd20 60000000 60000000 3c82ff36 7fe3fb78 
> > > [  302.855689] fb210068 38843b78 48062f09 60000000 <0fe00000> 60000000 3b400001 3b600001 
> > > [  302.855950] ---[ end trace a52140e0f9751ae0 ]---
> > > 
> > > What seems to be happening is migrate_page_move_mapping() calling
> > > page_ref_freeze() on another cpu somewhere between __migration_entry_wait()
> > > taking a reference and wait_on_page_bit_common() calling page_put().
> > 
> > Thank you for reporting, Artem.
> > 
> > And see the mm thread https://marc.info/?l=linux-mm&m=154821775401218&w=2
> 
> Ah, thank you. Should have searched through linux-mm, not just lkml.
> 
> > That was on arm64, you are on power I think: both point towards xfs
> > (Cai could not reproduce it on ext4), but that should not be taken too
> > seriously - it could just be easier to reproduce on one than the other.
> > 
> > Your description in your last paragraph is what I imagined happening too.
> > And nothing wrong with that, except that the page_ref_freeze() should
> > have failed, but succeeded.  We believe that something has done an
> > improper put_page(), on a libc-2.28.so page that's normally always
> > in use, and the put_and_wait_on_page_locked() commit has exposed that
> > by making its migration possible when it was almost impossible before
> > (Cai has reproduced it without the put_and_wait_on_page_locked commit).
> 
> This is what I saw as well, only reproduces on xfs and page_ref_count == 0
> BUG through generic_file_buffered_read() when your patch is reverted.
> Wasn't sure that's the same issue though.
> 
> > I don't think any of us have made progress on this since the 25th.
> > I'll wrap up what I'm working on in the next hour or two, and switch
> > my attention to this. Even if put_and_wait_on_page_locked() happens to
> > be correct, and just makes a pre-existing bug much easier to hit, we
> > shall have to revert it from 5.0 if we cannot find the right answer
> > in the next week or so.  Which would be sad: I'll try to rescue it,
> > but don't have great confidence that I'll be successful.
> > 
> > I'll be looking through the source, thinking around it, and trying
> > to find a surplus put_page(). I don't have any experiments in mind
> > to try at this stage.
> > 
> > Something I shall not be doing, is verifying the correctness of the
> > low-level get_page_unless_zero() versus page_ref_freeze() protocol
> > on arm64 and power - nobody has reported on x86, and I do wonder if
> > there's a barrier missing somewhere, that could manifest in this way -
> > but I'm unlikely to be the one to find that (and also think that any
> > weakness there should have shown up long before now).
> 
> I tried reproducing it with 5.0-rc5 and failed. There is one patch that
> seems to be fixing an xfs page reference issue which to me sounds a lot
> like what you describe.  The patch is 8e47a457321c "iomap: get/put the
> page in iomap_page_create/release()". That would explain why
> page_ref_freeze() and all the expected_page_refs() checks succeed when
> they shouldn't.

Yes! I'm sure you've got it, that fits exactly, thank you so much Artem.
iomap_migrate_page() was very much on my search path yesterday, but I
was looking at latest source, had missed checking it for recent fixes.

> 
> Apart from no longer reproducing the bug I also see a drastic reduce in
> pgmigrate_fails in /proc/vmstat (from tens of thousands and
> being >pgmigrate_success, to just tens) so I assume it is possible for it
> to be just masking the problem by performing less retries. What do you think?

I'm a little surprised that it managed to get as far as so many fails
without crashing, when it had the refcounting wrong like that: but I'm
sure you've found the root fix, not something masking the bug.

> 
> Cai, can you please check if you can reproduce this issue in your
> environment with 5.0-rc5?

Yes, please do - practical confirmation more convincing than my certainty.

(Linus, I'll reply a little to yours later.)

Hugh

