Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AA119C10F0B
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 00:31:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5AA272084A
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 00:31:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="MGvHXLaj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5AA272084A
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D10F86B0269; Tue,  2 Apr 2019 20:31:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CBE7D6B026D; Tue,  2 Apr 2019 20:31:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B5FB36B026F; Tue,  2 Apr 2019 20:31:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 36A596B0269
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 20:31:16 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id f1so11010366pgv.12
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 17:31:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=n2dsX0R8VOBMrOrZi+SHn9nLA+n4Op098PKZvmocm18=;
        b=FZ2NTPqGthiL5rNh0EcMnnFuAbH2CsNBOln6qo/IXUPOxraJ2atb6vjcxh+VmNcL51
         5VflJjqyImCsfGN/8bmfjVhq2N/OU76OKDl3pOkVEdiLWDDaQKtf2hBItZgKLx6PY3S2
         4BjPl2bfuhY9jL7d4RG0jFfX14KV+1283BgpIf0HdxWUXFUbNb2W7z4MGt74tTtCx6D0
         Qgov5OSskxX5/W9eWEMXfVngkrZpz44qtlQxQP6+g+XxHWn1t/KN6QkmV5v2e0PAdgV2
         7iytqp4QtyQR8I3ePYxgWh6uYTMPeOSfdcFbZnoafPjNsgYYNqzJI6v/4MVWKMkTV3bf
         Yyrw==
X-Gm-Message-State: APjAAAU9GH0P7D69yz+VrPcZ4V10/Yse7yqrrsY1WshTSGxMHhfS94BA
	N0BJysC+FORDm0laxkMSgthzB716K4cHXoNPDH0n9QwjKk+jqLn+xkS/ZKdhd+WIGr+neHlf2yV
	LMJ8B2ZrAdn9kCuhr2tmVSC0Sduxe3pNraApCjr6+tuerEymPVK01EMB3xuv0zE0eXg==
X-Received: by 2002:a63:30c5:: with SMTP id w188mr45482229pgw.76.1554251475784;
        Tue, 02 Apr 2019 17:31:15 -0700 (PDT)
X-Received: by 2002:a63:30c5:: with SMTP id w188mr45482119pgw.76.1554251474654;
        Tue, 02 Apr 2019 17:31:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554251474; cv=none;
        d=google.com; s=arc-20160816;
        b=CWdGDvUoeQBrqxIwj4IWU1YOibOZbtI1OMxM3J9RjjLcexIizvC5icAuHWyy3LHSGL
         uawRuYWSZBc5H8aBc73kXqIissuQPLvs5TYM1YrxAltqujQMhVbNEBjSdLYZlP/HsEqq
         YNTNHfeHiVsb+aN3sPNYNhFhVX6hiE61P+UAGPhrNYuxQzdaX3pG8WDGrOUCejhFiXWk
         nJOl8bn3lYHRr2pTVp393efk0tqgZFesHpqMI7jKhPKxC2cX/c74VesYtkXgRMOnnAZo
         OgyyQ2BazAjtPZbxaeUP/cjawVisl9rE1LDZGcjYTinGMFzRIggIx0A+Gn7HX3CBfqUc
         W4pw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=n2dsX0R8VOBMrOrZi+SHn9nLA+n4Op098PKZvmocm18=;
        b=HFF4MNZhevDuMg6qBSLP1dZwlRlPa6Z7KUBm/w06lYN5kdIJeO0ZSeVyhQIQEyDNQC
         AHOvyiC2ipuYZZYv7uCXD4pDhs1WLHnIx+TKMU++R8yw8PQm3SNsvkB3UXk8TXQLf25M
         cciOJ9FKl73RoUor1J0BrjBzKV5IRYNasZN35a659smh5xz56Hdqw1L9VRztS2jbjyVH
         bVxnZKMuhF4cAXuBpMLmz0xoqmlesjLHmgfOf4SH3U/LRT0ke8R4n5JpZ0oO9auDyk3z
         yv1UlKjy5/BczZRmu23n0FB/umf50OFMeycUyrtlgfRLnPXOm5+wT64/45lUOUjNmokd
         O9VQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=MGvHXLaj;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s87sor14938824pfa.62.2019.04.02.17.31.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Apr 2019 17:31:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=MGvHXLaj;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=n2dsX0R8VOBMrOrZi+SHn9nLA+n4Op098PKZvmocm18=;
        b=MGvHXLajEkZYqBMYxvWthMt01ZfIkkSjBONDsK27h6jq47aHe/aBqTtCrR+veegBth
         H0y+KqQnIq4a5iqKaEdeSMJmaUMUOSkPqTdJhMN1x1TH2D3LSOGGcHvRp0zbmqvdhoIP
         M9t0/IUp8bQ6cYop55esJ5jCpbqFy8868tU1QzcgaypajUvOCPxrjRA7tHLHpeoA8ulF
         oS2JU/0MBjxHGcc7BxGOMIq14gxcs2tU3ptoovrmpsGKX0w1UlDk4dNpmuOoNKs696e9
         zMZxCZJfrITdZe9fITvbwRKPFJCtLboKJ8mxasGts7nfK4JgJFOMFG30O83fyVjuKIfs
         XYKg==
X-Google-Smtp-Source: APXvYqziX1ApDI+q53pGhP23LTIArTYjM+6R3yWYlQ7UPVMBcBdtueu31ZANVauRmtp+akWGZCDb1w==
X-Received: by 2002:a62:61c2:: with SMTP id v185mr21047988pfb.117.1554251473291;
        Tue, 02 Apr 2019 17:31:13 -0700 (PDT)
Received: from [100.112.89.103] ([104.133.8.103])
        by smtp.gmail.com with ESMTPSA id k14sm15543948pfb.125.2019.04.02.17.31.11
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 02 Apr 2019 17:31:12 -0700 (PDT)
Date: Tue, 2 Apr 2019 17:30:52 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
X-X-Sender: hugh@eggly.anvils
To: "Alex Xu (Hello71)" <alex_y_xu@yahoo.ca>
cc: Hugh Dickins <hughd@google.com>, 
    Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, 
    Vineeth Pillai <vpillai@digitalocean.com>, 
    Andrew Morton <akpm@linux-foundation.org>, 
    Kelley Nielsen <kelleynnn@gmail.com>, linux-kernel@vger.kernel.org, 
    linux-mm@kvack.org, Rik van Riel <riel@surriel.com>, 
    Huang Ying <ying.huang@intel.com>
Subject: Re: shmem_recalc_inode: unable to handle kernel NULL pointer
 dereference
In-Reply-To: <alpine.LSU.2.11.1903311146040.2667@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1904021701270.5045@eggly.anvils>
References: <1553440122.7s759munpm.astroid@alex-desktop.none> <CANaguZB8szw13MkaiT9kcN8Fux6hYZnuD-p6_OPve6n2fOTuoQ@mail.gmail.com> <1554048843.jjmwlalntd.astroid@alex-desktop.none> <alpine.LSU.2.11.1903311146040.2667@eggly.anvils>
User-Agent: Alpine 2.11 (LSU 23 2013-08-11)
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 31 Mar 2019, Hugh Dickins wrote:
> On Sun, 31 Mar 2019, Alex Xu (Hello71) wrote:
> > Excerpts from Vineeth Pillai's message of March 25, 2019 6:08 pm:
> > > On Sun, Mar 24, 2019 at 11:30 AM Alex Xu (Hello71) <alex_y_xu@yahoo.ca> wrote:
> > >>
> > >> I get this BUG in 5.1-rc1 sometimes when powering off the machine. I
> > >> suspect my setup erroneously executes two swapoff+cryptsetup close
> > >> operations simultaneously, so a race condition is triggered.
> > >>
> > >> I am using a single swap on a plain dm-crypt device on a MBR partition
> > >> on a SATA drive.
> > >>
> > >> I think the problem is probably related to
> > >> b56a2d8af9147a4efe4011b60d93779c0461ca97, so CCing the related people.
> > >>
> > > Could you please provide more information on this - stack trace, dmesg etc?
> > > Is it easily reproducible? If yes, please detail the steps so that I
> > > can try it inhouse.
> > > 
> > > Thanks,
> > > Vineeth
> > > 
> > 
> > Some info from the BUG entry (I didn't bother to type it all, 
> > low-quality image available upon request):
> > 
> > BUG: unable to handle kernel NULL pointer dereference at 0000000000000000
> > #PF error: [normal kernel read fault]
> > PGD 0 P4D 0
> > Oops: 0000 [#1] SMP
> > CPU: 0 Comm: swapoff Not tainted 5.1.0-rc1+ #2
> > RIP: 0010:shmem_recalc_inode+0x41/0x90
> > 
> > Call Trace:
> > ? shmem_undo_range
> > ? rb_erase_cached
> > ? set_next_entity
> > ? __inode_wait_for_writeback
> > ? shmem_truncate_range
> > ? shmem_evict_inode
> > ? evict
> > ? shmem_unuse
> > ? try_to_unuse
> > ? swapcache_free_entries
> > ? _cond_resched
> > ? __se_sys_swapoff
> > ? do_syscall_64
> > ? entry_SYSCALL_64_after_hwframe
> > 
> > As I said, it only occurs occasionally on shutdown. I think it is a safe 
> > guess that it can only occur when the swap is not empty, but possibly 
> > other conditions are necessary, so I will test further.
> 
> Thanks for the update, Alex. I'm looking into a couple of bugs with the
> 5.1-rc swapoff, but this one doesn't look like anything I know so far.
> shmem_recalc_inode() is a surprising place to crash: it's as if the
> igrab() in shmem_unuse() were not working. 
> 
> Yes, please do send Vineeth and me (or the lists) your low-quality image,
> in case we can extract any more info from it; and also please the
> disassembly of your kernel's shmem_recalc_inode(), so we can be sure of
> exactly what it's crashing on (though I expect that will leave me as
> puzzled as before).
> 
> If you want to experiment with one of my fixes, not yet written up and
> posted, just try changing SWAP_UNUSE_MAX_TRIES in mm/swapfile.c from
> 3 to INT_MAX: I don't see how that issue could manifest as crashing in
> shmem_recalc_inode(), but I may just be too stupid to see it.

Thanks for the image and disassembly you sent: which showed that the
ffffffff81117351:       48 83 3f 00             cmpq   $0x0,(%rdi)
you are crashing on, is the "if (sbinfo->max_blocks)" in the inlined
shmem_inode_unacct_blocks(): inode->i_sb->s_fs_info is NULL, which is
something that shmem_put_super() does.

Eight-year-old memories stirred: I knew when looking at Vineeth's patch,
that I ought to look back through the history of mm/shmem.c, to check
some points that Konstantin Khlebnikov had made years ago, that
surprised me then and were in danger of surprising us again with this
rework. But I failed to do so: thank you Alex, for reporting this bug
and pointing us back there.

igrab() protects from eviction but does not protect from unmounting.
I bet that is what you are hitting, though I've not even read through
2.6.39's 778dd893ae785 ("tmpfs: fix race between umount and swapoff")
again yet, and not begun to think of the fix for it this time around;
but wanted to let you know that this bug is now (probably) identified.

Hugh

