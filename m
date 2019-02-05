Return-Path: <SRS0=TNGr=QM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5D8ACC282D7
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 12:10:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 17BC02080F
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 12:10:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 17BC02080F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 92F018E0084; Tue,  5 Feb 2019 07:10:07 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 90FA38E0083; Tue,  5 Feb 2019 07:10:07 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7F68D8E0084; Tue,  5 Feb 2019 07:10:07 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 585E38E0083
	for <linux-mm@kvack.org>; Tue,  5 Feb 2019 07:10:07 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id b187so3046065qkf.3
        for <linux-mm@kvack.org>; Tue, 05 Feb 2019 04:10:07 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=oiy6JzHwzSQ83120zG1UPME/oeByW6/N2NFusvCjbhM=;
        b=dK/7ozabKqUrzVb1YaNaBj8Rj2WGyIi6h/HcgGr6aa/RJs1OUDOiffHuaaBGqnOcLY
         ZF93veAEAcaL881wHeZQFG+PB2Z+b5ppVAEfd9yLAUwhmyVS74uYeDSKzxsMEl3NLhjU
         nMdxH/jUzTrZ479wVyB7NMk2uZUzVPFTRHjRGmVUBvyLwTOqfq+5CZ1Gp6eby1Qp63q2
         3rGNZGvC8NpyJTeq/2UE15+C9U+LCMt2+hQ/Ipz+cnvP0DFeMKu9kfRIWUt+wfmHeVZw
         68Z4i3au/hjw9bEzaf1OeNBfDW6SgVOisFrAfn62KOSdowTdCdtrUXrQsZcmRh9xousl
         FCdA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of asavkov@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=asavkov@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuZyWzOv04jkesLCnoL5HgLlDy1rXilXoUcu/yE6NY8PAzNTQXmy
	EEVS9JpT3bUZgy+2Gynevvf8W50HOUwEacYN7e/lNxNLIs0E/fksTDVMT3r0cy4EoW2bEABf6Q2
	5tIFxKussVJe/hpwYfgC2rgSUML8NoEHdMQjAYLwbfAHW/kCVL8UzE8TjsxXnxcLesA==
X-Received: by 2002:aed:2558:: with SMTP id w24mr3244069qtc.183.1549368607041;
        Tue, 05 Feb 2019 04:10:07 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZLglHHOSv445mnUTpko+baQiS/rgSpMakp97ttK29ZH2vMy8EH37/dqqf5ZZVGhQiM2iWT
X-Received: by 2002:aed:2558:: with SMTP id w24mr3244008qtc.183.1549368605938;
        Tue, 05 Feb 2019 04:10:05 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549368605; cv=none;
        d=google.com; s=arc-20160816;
        b=zOEGraQT1PJ97Ssh4AEeBkhuxjDEWwvbnFpyFnfmsrWVJNRuKrZWpJ2ipkj4WMaWNC
         JKNPU959u+ZKltphaGTp9I2EfTbIAXqHmkF8bVentGYl5ZWwpY+iEXSmsuYZyd5ejQDQ
         wpBKnT0bGM+/yUbB2vceSCkD/nIqm4P923f1eP2PMypO93G6VqxKq6GGOlDabAL0lHIG
         eflQMXidG4kXvs8x3UXnimZiToQFyuqyS86Q81agMDkcbbxVSunn4VC5+AJRgjaIHxXn
         bLip/cAqYKYr8BaJq950Xu5JTs3PPGnuTgZnGedy0yyuvAXcmULO3xYTOZOLVWVRb+HV
         v/BQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=oiy6JzHwzSQ83120zG1UPME/oeByW6/N2NFusvCjbhM=;
        b=ixC4pBgVdIme2qstIt2sqcrI3YDmA+KDnBLK+5FyRojTICNZ9MUWOFfMDAE0AJOlGn
         FdqD714xrtfz6xCTdeJ3JMdzFR3RDPCIKUWe0QFW10gpZq8f55oOADPWPiXfuR8AquOo
         wp92r/+raZ1QRynz93Mil4k2m+93+akYRoPsVpe2Nml0q+tTzu400lzPTJNcTUoG70/7
         GThhajxlb2vxaaNCPSXvSGtmNm00iHcqqmsFNFWwhh1Gn0X9D/ev9EHeHwdKvHkn0bUi
         nL/Hrd7OrvK93y4Uf3iIgM9cxE7W+XMR+KP//3p34lgkb2m/yjwt8Q2SuQs/Sdzq8GpK
         9kGA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of asavkov@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=asavkov@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j23si1809356qkk.232.2019.02.05.04.10.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Feb 2019 04:10:05 -0800 (PST)
Received-SPF: pass (google.com: domain of asavkov@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of asavkov@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=asavkov@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 654EF87620;
	Tue,  5 Feb 2019 12:10:04 +0000 (UTC)
Received: from shodan.usersys.redhat.com (unknown [10.43.17.28])
	by smtp.corp.redhat.com (Postfix) with ESMTP id B00151048116;
	Tue,  5 Feb 2019 12:10:03 +0000 (UTC)
Received: by shodan.usersys.redhat.com (Postfix, from userid 1000)
	id C782F2C0AD2; Tue,  5 Feb 2019 13:10:02 +0100 (CET)
Date: Tue, 5 Feb 2019 13:10:02 +0100
From: Artem Savkov <asavkov@redhat.com>
To: Hugh Dickins <hughd@google.com>
Cc: Baoquan He <bhe@redhat.com>, Qian Cai <cai@lca.pw>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: mm: race in put_and_wait_on_page_locked()
Message-ID: <20190205121002.GA32424@shodan.usersys.redhat.com>
References: <20190204091300.GB13536@shodan.usersys.redhat.com>
 <alpine.LSU.2.11.1902041201280.4441@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1902041201280.4441@eggly.anvils>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Tue, 05 Feb 2019 12:10:04 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 04, 2019 at 12:42:50PM -0800, Hugh Dickins wrote:
> On Mon, 4 Feb 2019, Artem Savkov wrote:
> 
> > Hi Hugh,
> > 
> > Your recent patch 9a1ea439b16b "mm: put_and_wait_on_page_locked() while
> > page is migrated" seems to have introduced a race into page migration
> > process. I have a host that eagerly reproduces the following BUG under
> > stress:
> > 
> > [  302.847402] page:f000000000021700 count:0 mapcount:0 mapping:c0000000b2710bb0 index:0x19
> > [  302.848096] xfs_address_space_operations [xfs] 
> > [  302.848100] name:"libc-2.28.so" 
> > [  302.848244] flags: 0x3ffff800000006(referenced|uptodate)
> > [  302.848521] raw: 003ffff800000006 5deadbeef0000100 5deadbeef0000200 0000000000000000
> > [  302.848724] raw: 0000000000000019 0000000000000000 00000001ffffffff c0000000bc0b1000
> > [  302.848919] page dumped because: VM_BUG_ON_PAGE(page_ref_count(page) == 0)
> > [  302.849076] page->mem_cgroup:c0000000bc0b1000
> > [  302.849269] ------------[ cut here ]------------
> > [  302.849397] kernel BUG at include/linux/mm.h:546!
> > [  302.849586] Oops: Exception in kernel mode, sig: 5 [#1]
> > [  302.849711] LE SMP NR_CPUS=2048 NUMA pSeries
> > [  302.849839] Modules linked in: pseries_rng sunrpc xts vmx_crypto virtio_balloon xfs libcrc32c virtio_net net_failover virtio_console failover virtio_blk
> > [  302.850400] CPU: 3 PID: 8759 Comm: cc1 Not tainted 5.0.0-rc4+ #36
> > [  302.850571] NIP:  c00000000039c8b8 LR: c00000000039c8b4 CTR: c00000000080a0e0
> > [  302.850758] REGS: c0000000b0d7f7e0 TRAP: 0700   Not tainted  (5.0.0-rc4+)
> > [  302.850952] MSR:  8000000000029033 <SF,EE,ME,IR,DR,RI,LE>  CR: 48024422  XER: 00000000
> > [  302.851150] CFAR: c0000000003ff584 IRQMASK: 0 
> > [  302.851150] GPR00: c00000000039c8b4 c0000000b0d7fa70 c000000001bcca00 0000000000000021 
> > [  302.851150] GPR04: c0000000b044c628 0000000000000007 55555555555555a0 c000000001fc3760 
> > [  302.851150] GPR08: 0000000000000007 0000000000000000 c0000000b0d7c000 c0000000b0d7f5ff 
> > [  302.851150] GPR12: 0000000000004400 c00000003fffae80 0000000000000000 0000000000000000 
> > [  302.851150] GPR16: 0000000000000000 0000000000000000 0000000000000000 0000000000000000 
> > [  302.851150] GPR20: c0000000689f5aa8 c00000002a13ee48 0000000000000000 c000000001da29b0 
> > [  302.851150] GPR24: c000000001bf7d80 c0000000689f5a00 0000000000000000 0000000000000000 
> > [  302.851150] GPR28: c000000001bf9e80 c0000000b0d7fab8 0000000000000001 f000000000021700 
> > [  302.852914] NIP [c00000000039c8b8] put_and_wait_on_page_locked+0x398/0x3d0
> > [  302.853080] LR [c00000000039c8b4] put_and_wait_on_page_locked+0x394/0x3d0
> > [  302.853235] Call Trace:
> > [  302.853305] [c0000000b0d7fa70] [c00000000039c8b4] put_and_wait_on_page_locked+0x394/0x3d0 (unreliable)
> > [  302.853540] [c0000000b0d7fb10] [c00000000047b838] __migration_entry_wait+0x178/0x250
> > [  302.853738] [c0000000b0d7fb50] [c00000000040c928] do_swap_page+0xd78/0xf60
> > [  302.853997] [c0000000b0d7fbd0] [c000000000411078] __handle_mm_fault+0xbf8/0xe80
> > [  302.854187] [c0000000b0d7fcb0] [c000000000411548] handle_mm_fault+0x248/0x450
> > [  302.854379] [c0000000b0d7fd00] [c000000000078ca4] __do_page_fault+0x2d4/0xdf0
> > [  302.854877] [c0000000b0d7fde0] [c0000000000797f8] do_page_fault+0x38/0xf0
> > [  302.855057] [c0000000b0d7fe20] [c00000000000a7c4] handle_page_fault+0x18/0x38
> > [  302.855300] Instruction dump:
> > [  302.855432] 4bfffcf0 60000000 3948ffff 4bfffd20 60000000 60000000 3c82ff36 7fe3fb78 
> > [  302.855689] fb210068 38843b78 48062f09 60000000 <0fe00000> 60000000 3b400001 3b600001 
> > [  302.855950] ---[ end trace a52140e0f9751ae0 ]---
> > 
> > What seems to be happening is migrate_page_move_mapping() calling
> > page_ref_freeze() on another cpu somewhere between __migration_entry_wait()
> > taking a reference and wait_on_page_bit_common() calling page_put().
> 
> Thank you for reporting, Artem.
> 
> And see the mm thread https://marc.info/?l=linux-mm&m=154821775401218&w=2

Ah, thank you. Should have searched through linux-mm, not just lkml.

> That was on arm64, you are on power I think: both point towards xfs
> (Cai could not reproduce it on ext4), but that should not be taken too
> seriously - it could just be easier to reproduce on one than the other.
> 
> Your description in your last paragraph is what I imagined happening too.
> And nothing wrong with that, except that the page_ref_freeze() should
> have failed, but succeeded.  We believe that something has done an
> improper put_page(), on a libc-2.28.so page that's normally always
> in use, and the put_and_wait_on_page_locked() commit has exposed that
> by making its migration possible when it was almost impossible before
> (Cai has reproduced it without the put_and_wait_on_page_locked commit).

This is what I saw as well, only reproduces on xfs and page_ref_count == 0
BUG through generic_file_buffered_read() when your patch is reverted.
Wasn't sure that's the same issue though.

> I don't think any of us have made progress on this since the 25th.
> I'll wrap up what I'm working on in the next hour or two, and switch
> my attention to this. Even if put_and_wait_on_page_locked() happens to
> be correct, and just makes a pre-existing bug much easier to hit, we
> shall have to revert it from 5.0 if we cannot find the right answer
> in the next week or so.  Which would be sad: I'll try to rescue it,
> but don't have great confidence that I'll be successful.
> 
> I'll be looking through the source, thinking around it, and trying
> to find a surplus put_page(). I don't have any experiments in mind
> to try at this stage.
> 
> Something I shall not be doing, is verifying the correctness of the
> low-level get_page_unless_zero() versus page_ref_freeze() protocol
> on arm64 and power - nobody has reported on x86, and I do wonder if
> there's a barrier missing somewhere, that could manifest in this way -
> but I'm unlikely to be the one to find that (and also think that any
> weakness there should have shown up long before now).

I tried reproducing it with 5.0-rc5 and failed. There is one patch that
seems to be fixing an xfs page reference issue which to me sounds a lot
like what you describe.  The patch is 8e47a457321c "iomap: get/put the
page in iomap_page_create/release()". That would explain why
page_ref_freeze() and all the expected_page_refs() checks succeed when
they shouldn't.

Apart from no longer reproducing the bug I also see a drastic reduce in
pgmigrate_fails in /proc/vmstat (from tens of thousands and
being >pgmigrate_success, to just tens) so I assume it is possible for it
to be just masking the problem by performing less retries. What do you think?

Cai, can you please check if you can reproduce this issue in your
environment with 5.0-rc5?

-- 
 Artem

