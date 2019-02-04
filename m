Return-Path: <SRS0=bR/Z=QL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9A62FC282CC
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 20:43:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 417AD2080D
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 20:43:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="tFOHSsym"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 417AD2080D
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C85E68E005D; Mon,  4 Feb 2019 15:43:01 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C325E8E001C; Mon,  4 Feb 2019 15:43:01 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B49188E005D; Mon,  4 Feb 2019 15:43:01 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6EB098E001C
	for <linux-mm@kvack.org>; Mon,  4 Feb 2019 15:43:01 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id p20so703568plr.22
        for <linux-mm@kvack.org>; Mon, 04 Feb 2019 12:43:01 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=kk6MwTpxjihccu+ylol4Y3Kbog2koihAsmNoJGT+zfQ=;
        b=JhOHtfYV/XsWnEd6xqwFrUWHak1PS1xJBexncg1xyP7SDNWW1M3cy7nXlXCaIx7Jef
         vHOr36n57dGaquO1yHubIANMXlq3ykP/bMWkvEcD//z6D2Z4FFKxd2WuK6nld+egvAVp
         CfqYsTcv/JwS38X/CmWcJK+DR50ZmKOJwT57b7uUJhWaqyx2BTaGKJpb6+M/H4dWZkrc
         VvrOdEtUG4J0GdAlW3Rm4M6Dtel/CewWtf7mgBJNCtGv9GLByiA9UBhgSzIwH1rsNqiK
         QKhGArzUnmf/3j2lPB4qZ8ClWsubIxxQO3ln+wlSUpzJZy20LRfez68urxVM51bRRmwk
         5i2w==
X-Gm-Message-State: AHQUAuZCWPCqn8439jzPlI86O9XRSR4cQNadyIb6QE0YLLAILz+pfcL4
	QuLteqj+B3w58NWTzjMK9hXZ18jMmF+FjqN3EtpQe+E7ps9MDuxjUohZtKs8CnuqzDnOQTJpziZ
	xLDw0tnE2EUdmvoMVveEU3q4rrAqLaNqksJbPHaK7mhgcyPKDBcwwRnQzCSaRiB4JEri/wHICov
	2MzPwnK0zb+Cx4agzaUnjafNDJEprLAKEZB3LcAXMQwlpTm5L++9ycjQp8IVqmvKjZnjFxvXv9G
	wODD4Oy3ZdfqRADMmpzkOL6FEI8OEzYdrUbkBnC7Fwpb9tzPYSIDd8D4JDzPoZYlE7uV8M/qweg
	Yn/QhcK6/okGf2+IkU6SZRuOKZWlETTYEHOXJMjS5vVScjfySpCErTPB7AjJpHEtrxnbejHSNAt
	z
X-Received: by 2002:a17:902:b118:: with SMTP id q24mr1302105plr.209.1549312981023;
        Mon, 04 Feb 2019 12:43:01 -0800 (PST)
X-Received: by 2002:a17:902:b118:: with SMTP id q24mr1302049plr.209.1549312979996;
        Mon, 04 Feb 2019 12:42:59 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549312979; cv=none;
        d=google.com; s=arc-20160816;
        b=Tr1FwrS8hvDpMooJgi7B9NQ570bZBqqZO8w2uZE7ifDhI1dnF48xnB3RttUsQovUZg
         Cxc7Z159M1xu46uSjAD1DMJKUNGCZesUElliwom7mcUP89cXRrsY+KkaQCnXIzIPDRGx
         uq5gyGGqhamHlV92VU6PMgClzgBGERKDoRKkHPKCf58ZtkG4FU0PFBYkU37fFBvjKRha
         vjcoPBLigMPbrb1XGjDpnQxscvxVcBQNt/umNKEwcEKM9TlCi9KmUVjuNu9I0SrvrG72
         2aGJvVi6xIRKQiuYsonFTBPWlp4HPTbnYUQtReD59DfT2Tf46ZGfLT3Ndk+b2MNIbOal
         IdnA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=kk6MwTpxjihccu+ylol4Y3Kbog2koihAsmNoJGT+zfQ=;
        b=Pd2qMHyjdtDDd0VKRrL5cvkIOP/4NC9y+avYdb9/zQH4yzlusI6zeOZOsi1ZmD8L0b
         0pR+pDr/NlhNQack0EsEi+/CUbqgwyWBGi/ik4GQzHOpdSRgh2vLdwth1tnCIc77Ym/2
         bxMbMk/zylPEClwxaO7Fy3eNyqpbip2ybZL3x3bpo6xF6H55ShMMVJeoExVnLJYyVuwE
         YKu65yIi0abGUD5eHpR1EdEFiVg5PzFi60IBEvUn5FDOsFz3urYVoluHbz3FM1uMFZUy
         d5D23w5U54rBJx4/heo5uHcHw+QNV/9I7DtlsshHK4y5XnJbWyUs0PD+EnBrmk7O7cWz
         nXlA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=tFOHSsym;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a33sor1740040pla.29.2019.02.04.12.42.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 04 Feb 2019 12:42:59 -0800 (PST)
Received-SPF: pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=tFOHSsym;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=kk6MwTpxjihccu+ylol4Y3Kbog2koihAsmNoJGT+zfQ=;
        b=tFOHSsymn9owFLGajQZCJA1UVDbpvu5HgGVuP7S9Fum4DuxQz/3BkuGAXugdSGOWrd
         ZjYkbT9UT8y9IUknr8TOkX7iM+iF5Vu5dpFjLaDJxYZOY6rwqgeFPDJHTBBK/f6ccpjx
         vVta/Q3aVtoif+9WWH7sT70koFRtky5kPfD4Z5yn9qjhkyCLCRnSYG390uNF31gwZzz9
         x5PPmXFfkuje9GpBRrsgLaiMjbFgDX5j0Qk4toB8ZSc8T0v3h+bALrLm4dTlr9nqcF8y
         Gmgp9jVAoM2DoyKKsgwm2qGe8bxLeRd5Hxp3GpeWYyidCuIAM8MgrtcZdLRs6A7yYfi5
         W40Q==
X-Google-Smtp-Source: AHgI3IaB7O9ZkORKD9EDbQJ+es/Vkrsf3vnRn3JkRihTYrL8jFlK3C7AthMcPujrEoSlEbmNajOlBw==
X-Received: by 2002:a17:902:6948:: with SMTP id k8mr1337453plt.2.1549312979106;
        Mon, 04 Feb 2019 12:42:59 -0800 (PST)
Received: from [100.112.89.103] ([104.133.8.103])
        by smtp.gmail.com with ESMTPSA id b9sm994459pgt.66.2019.02.04.12.42.57
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 04 Feb 2019 12:42:58 -0800 (PST)
Date: Mon, 4 Feb 2019 12:42:50 -0800 (PST)
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
In-Reply-To: <20190204091300.GB13536@shodan.usersys.redhat.com>
Message-ID: <alpine.LSU.2.11.1902041201280.4441@eggly.anvils>
References: <20190204091300.GB13536@shodan.usersys.redhat.com>
User-Agent: Alpine 2.11 (LSU 23 2013-08-11)
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 4 Feb 2019, Artem Savkov wrote:

> Hi Hugh,
> 
> Your recent patch 9a1ea439b16b "mm: put_and_wait_on_page_locked() while
> page is migrated" seems to have introduced a race into page migration
> process. I have a host that eagerly reproduces the following BUG under
> stress:
> 
> [  302.847402] page:f000000000021700 count:0 mapcount:0 mapping:c0000000b2710bb0 index:0x19
> [  302.848096] xfs_address_space_operations [xfs] 
> [  302.848100] name:"libc-2.28.so" 
> [  302.848244] flags: 0x3ffff800000006(referenced|uptodate)
> [  302.848521] raw: 003ffff800000006 5deadbeef0000100 5deadbeef0000200 0000000000000000
> [  302.848724] raw: 0000000000000019 0000000000000000 00000001ffffffff c0000000bc0b1000
> [  302.848919] page dumped because: VM_BUG_ON_PAGE(page_ref_count(page) == 0)
> [  302.849076] page->mem_cgroup:c0000000bc0b1000
> [  302.849269] ------------[ cut here ]------------
> [  302.849397] kernel BUG at include/linux/mm.h:546!
> [  302.849586] Oops: Exception in kernel mode, sig: 5 [#1]
> [  302.849711] LE SMP NR_CPUS=2048 NUMA pSeries
> [  302.849839] Modules linked in: pseries_rng sunrpc xts vmx_crypto virtio_balloon xfs libcrc32c virtio_net net_failover virtio_console failover virtio_blk
> [  302.850400] CPU: 3 PID: 8759 Comm: cc1 Not tainted 5.0.0-rc4+ #36
> [  302.850571] NIP:  c00000000039c8b8 LR: c00000000039c8b4 CTR: c00000000080a0e0
> [  302.850758] REGS: c0000000b0d7f7e0 TRAP: 0700   Not tainted  (5.0.0-rc4+)
> [  302.850952] MSR:  8000000000029033 <SF,EE,ME,IR,DR,RI,LE>  CR: 48024422  XER: 00000000
> [  302.851150] CFAR: c0000000003ff584 IRQMASK: 0 
> [  302.851150] GPR00: c00000000039c8b4 c0000000b0d7fa70 c000000001bcca00 0000000000000021 
> [  302.851150] GPR04: c0000000b044c628 0000000000000007 55555555555555a0 c000000001fc3760 
> [  302.851150] GPR08: 0000000000000007 0000000000000000 c0000000b0d7c000 c0000000b0d7f5ff 
> [  302.851150] GPR12: 0000000000004400 c00000003fffae80 0000000000000000 0000000000000000 
> [  302.851150] GPR16: 0000000000000000 0000000000000000 0000000000000000 0000000000000000 
> [  302.851150] GPR20: c0000000689f5aa8 c00000002a13ee48 0000000000000000 c000000001da29b0 
> [  302.851150] GPR24: c000000001bf7d80 c0000000689f5a00 0000000000000000 0000000000000000 
> [  302.851150] GPR28: c000000001bf9e80 c0000000b0d7fab8 0000000000000001 f000000000021700 
> [  302.852914] NIP [c00000000039c8b8] put_and_wait_on_page_locked+0x398/0x3d0
> [  302.853080] LR [c00000000039c8b4] put_and_wait_on_page_locked+0x394/0x3d0
> [  302.853235] Call Trace:
> [  302.853305] [c0000000b0d7fa70] [c00000000039c8b4] put_and_wait_on_page_locked+0x394/0x3d0 (unreliable)
> [  302.853540] [c0000000b0d7fb10] [c00000000047b838] __migration_entry_wait+0x178/0x250
> [  302.853738] [c0000000b0d7fb50] [c00000000040c928] do_swap_page+0xd78/0xf60
> [  302.853997] [c0000000b0d7fbd0] [c000000000411078] __handle_mm_fault+0xbf8/0xe80
> [  302.854187] [c0000000b0d7fcb0] [c000000000411548] handle_mm_fault+0x248/0x450
> [  302.854379] [c0000000b0d7fd00] [c000000000078ca4] __do_page_fault+0x2d4/0xdf0
> [  302.854877] [c0000000b0d7fde0] [c0000000000797f8] do_page_fault+0x38/0xf0
> [  302.855057] [c0000000b0d7fe20] [c00000000000a7c4] handle_page_fault+0x18/0x38
> [  302.855300] Instruction dump:
> [  302.855432] 4bfffcf0 60000000 3948ffff 4bfffd20 60000000 60000000 3c82ff36 7fe3fb78 
> [  302.855689] fb210068 38843b78 48062f09 60000000 <0fe00000> 60000000 3b400001 3b600001 
> [  302.855950] ---[ end trace a52140e0f9751ae0 ]---
> 
> What seems to be happening is migrate_page_move_mapping() calling
> page_ref_freeze() on another cpu somewhere between __migration_entry_wait()
> taking a reference and wait_on_page_bit_common() calling page_put().

Thank you for reporting, Artem.

And see the mm thread https://marc.info/?l=linux-mm&m=154821775401218&w=2

That was on arm64, you are on power I think: both point towards xfs
(Cai could not reproduce it on ext4), but that should not be taken too
seriously - it could just be easier to reproduce on one than the other.

Your description in your last paragraph is what I imagined happening too.
And nothing wrong with that, except that the page_ref_freeze() should
have failed, but succeeded.  We believe that something has done an
improper put_page(), on a libc-2.28.so page that's normally always
in use, and the put_and_wait_on_page_locked() commit has exposed that
by making its migration possible when it was almost impossible before
(Cai has reproduced it without the put_and_wait_on_page_locked commit).

I don't think any of us have made progress on this since the 25th.
I'll wrap up what I'm working on in the next hour or two, and switch
my attention to this. Even if put_and_wait_on_page_locked() happens to
be correct, and just makes a pre-existing bug much easier to hit, we
shall have to revert it from 5.0 if we cannot find the right answer
in the next week or so.  Which would be sad: I'll try to rescue it,
but don't have great confidence that I'll be successful.

I'll be looking through the source, thinking around it, and trying
to find a surplus put_page(). I don't have any experiments in mind
to try at this stage.

Something I shall not be doing, is verifying the correctness of the
low-level get_page_unless_zero() versus page_ref_freeze() protocol
on arm64 and power - nobody has reported on x86, and I do wonder if
there's a barrier missing somewhere, that could manifest in this way -
but I'm unlikely to be the one to find that (and also think that any
weakness there should have shown up long before now).

Hugh

