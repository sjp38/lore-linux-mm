Return-Path: <SRS0=Vnw4=SC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 45B42C10F06
	for <linux-mm@archiver.kernel.org>; Sun, 31 Mar 2019 19:21:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D68ED21841
	for <linux-mm@archiver.kernel.org>; Sun, 31 Mar 2019 19:21:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Us8FORhm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D68ED21841
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 41C406B0003; Sun, 31 Mar 2019 15:21:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3CE6C6B0006; Sun, 31 Mar 2019 15:21:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2BB126B0007; Sun, 31 Mar 2019 15:21:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 009936B0003
	for <linux-mm@kvack.org>; Sun, 31 Mar 2019 15:21:38 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id w11so5317777otq.7
        for <linux-mm@kvack.org>; Sun, 31 Mar 2019 12:21:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=4yDtqtEgAp/LWVi4nPGb0Lvky010NJosRkxeKByHLt8=;
        b=RA43c0kXS9yELoPzfdcj518UlIUE1Nv5nW20sy//Wsa+Ax7ZGGnP3Ok+GOodIg1xND
         ZFIc2Ncp/giwPPnp5xoyZY82RinpFTCjCS1RGPphJDcyppRc7tcLv7CcIWi3VJF+K9eo
         deFqU271CC0JvCeNb2Ww3PziPlouuHHoh6WqfsxM4+XYWIKmWn+NVwase7lxm+Zs/Ux4
         wJSwpGedesrVu3OgriknO0VD5jTwy+ukCvED4c/eOD0J7ZZ78he0g8LnaDqHo8coOadw
         cZp6F9V5F+Dm72jvtFlVy+YG5SpbBmw4wDWyY6GmXvtFdmtCaXq1E+u2XhA+YgYspqzl
         g7zg==
X-Gm-Message-State: APjAAAXHmQ0BmiqNoGbIOlA+hJBKQ39OvpocBytJ9vVvP71jPb/bGcqS
	a2RUKC6ha+Ct01v0Jf2r63GcdIgbKjCMsiUGqkPg2j7xisMEgpWFlyGJhevk9f9bbD2pOhDrWiM
	s+SmdXhrpH0rdPsiytrxHYTYHBAmq/eYyLwGzbn9uTddysHvC4dCP8vZkB03eaxPt1w==
X-Received: by 2002:aca:44c6:: with SMTP id r189mr10433462oia.83.1554060098585;
        Sun, 31 Mar 2019 12:21:38 -0700 (PDT)
X-Received: by 2002:aca:44c6:: with SMTP id r189mr10433413oia.83.1554060097482;
        Sun, 31 Mar 2019 12:21:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554060097; cv=none;
        d=google.com; s=arc-20160816;
        b=t0YRnE2uOtRU1MmTqgYmBxRUc+uIEumFd8nI9jt1XpVWg//5F7l6fCU2sLVjRzRErt
         Wjfsf9VRrjVfyWSzudy0fem/lM+SzeWqKEzzYJmgutNqhxmMr2g4J5lAtN0FmOl8G6oY
         eTd9hgNEqrFJ0/FPpmK4qB7aUBczp9ukDQ+3M+4yPi0j6zWfgPjB4YULniNYtS6qIjpk
         8oE5JcY9uTCbSdi0j97QVNTAtTKA3oLN8datRvR6xOxwdZpkCP+TYKufFEo/ey+9Q8Tn
         +ci7Z9xOxsMmUKbVvtSr886vDII908W2FYp5UIk9PANJ0Ka7mqwq0lylq0SUqjKj9ToD
         8kCw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=4yDtqtEgAp/LWVi4nPGb0Lvky010NJosRkxeKByHLt8=;
        b=WibYeMV0G8iqdDFxlAHly7dElZjQ9QBitBb/OC0qSg/LVaTKyeCgDMN7yjuvnmT/WU
         PWXXJCW8KCWfjDq3aDgqfxgeoCB1S7yu1yH3UffLuYjGLIdt8D8tUi1RSsXIGXsRQFU3
         841QDNZ65rPq56WL9O90iAdPegHdbZrU1MJM8I0NZeJr0kCRfQpORl7eDmPCFxElcCSw
         THm074aYDZjk4TVuHJUChIlnvAtlJeoxYpkVrl3+6PAnn3sNaqL9Qs2yg4b36k6LCTkh
         wvVxpwtN37JQ0WBlJilRs7LdcKULWkHM6tVU7qhPuI5BiaQ6UoLA2xOIVb/D+45sRHdC
         5wbg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Us8FORhm;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b201sor4546152oii.81.2019.03.31.12.21.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 31 Mar 2019 12:21:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Us8FORhm;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=4yDtqtEgAp/LWVi4nPGb0Lvky010NJosRkxeKByHLt8=;
        b=Us8FORhmCR72lg0QlwJAtR8yhm/5UwSNt/znsLErlS+afM+kcangpnQDZnOqrlDPz8
         hdQesJkG3pQvPFeDD4FbkAKKUbomjBhNZ8myzhNdGn66YHrE97YEUBJiKix6l8scVh3w
         TtHECwTMNRvk0MwW1VZYJWIKGVUhxLlBPSFNCF7BZppy0ubCTmxQFOcNpzwxDX41/4bw
         ge4y3o+ha5xaSm/3WHmU8q6ZH+vK1D3hRma/iaz8G4G5sN48eF6CKiDB5YznnmbeUggN
         P89sJwK7HFqb8d8Cy5qMSFD4xIBq0n/k451jK2Ywr3uDCcBTao1hIO7GrAFuhUd9yT20
         WzhA==
X-Google-Smtp-Source: APXvYqzXJvQZMUNwegdIOLr2gkKsgtKnU57/PRrJJMa73WSU6Chpwhxlpk8tOgK2cHSakrAurOAvLw==
X-Received: by 2002:a54:4f85:: with SMTP id g5mr10144271oiy.35.1554060096864;
        Sun, 31 Mar 2019 12:21:36 -0700 (PDT)
Received: from eggly.attlocal.net (172-10-233-147.lightspeed.sntcca.sbcglobal.net. [172.10.233.147])
        by smtp.gmail.com with ESMTPSA id q25sm486885otl.60.2019.03.31.12.21.34
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 31 Mar 2019 12:21:35 -0700 (PDT)
Date: Sun, 31 Mar 2019 12:21:15 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
X-X-Sender: hugh@eggly.anvils
To: "Alex Xu (Hello71)" <alex_y_xu@yahoo.ca>
cc: Vineeth Pillai <vpillai@digitalocean.com>, 
    Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, 
    Kelley Nielsen <kelleynnn@gmail.com>, linux-kernel@vger.kernel.org, 
    linux-mm@kvack.org, Rik van Riel <riel@surriel.com>, 
    Huang Ying <ying.huang@intel.com>
Subject: Re: shmem_recalc_inode: unable to handle kernel NULL pointer
 dereference
In-Reply-To: <1554048843.jjmwlalntd.astroid@alex-desktop.none>
Message-ID: <alpine.LSU.2.11.1903311146040.2667@eggly.anvils>
References: <1553440122.7s759munpm.astroid@alex-desktop.none> <CANaguZB8szw13MkaiT9kcN8Fux6hYZnuD-p6_OPve6n2fOTuoQ@mail.gmail.com> <1554048843.jjmwlalntd.astroid@alex-desktop.none>
User-Agent: Alpine 2.11 (LSU 23 2013-08-11)
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 31 Mar 2019, Alex Xu (Hello71) wrote:
> Excerpts from Vineeth Pillai's message of March 25, 2019 6:08 pm:
> > On Sun, Mar 24, 2019 at 11:30 AM Alex Xu (Hello71) <alex_y_xu@yahoo.ca> wrote:
> >>
> >> I get this BUG in 5.1-rc1 sometimes when powering off the machine. I
> >> suspect my setup erroneously executes two swapoff+cryptsetup close
> >> operations simultaneously, so a race condition is triggered.
> >>
> >> I am using a single swap on a plain dm-crypt device on a MBR partition
> >> on a SATA drive.
> >>
> >> I think the problem is probably related to
> >> b56a2d8af9147a4efe4011b60d93779c0461ca97, so CCing the related people.
> >>
> > Could you please provide more information on this - stack trace, dmesg etc?
> > Is it easily reproducible? If yes, please detail the steps so that I
> > can try it inhouse.
> > 
> > Thanks,
> > Vineeth
> > 
> 
> Some info from the BUG entry (I didn't bother to type it all, 
> low-quality image available upon request):
> 
> BUG: unable to handle kernel NULL pointer dereference at 0000000000000000
> #PF error: [normal kernel read fault]
> PGD 0 P4D 0
> Oops: 0000 [#1] SMP
> CPU: 0 Comm: swapoff Not tainted 5.1.0-rc1+ #2
> RIP: 0010:shmem_recalc_inode+0x41/0x90
> 
> Call Trace:
> ? shmem_undo_range
> ? rb_erase_cached
> ? set_next_entity
> ? __inode_wait_for_writeback
> ? shmem_truncate_range
> ? shmem_evict_inode
> ? evict
> ? shmem_unuse
> ? try_to_unuse
> ? swapcache_free_entries
> ? _cond_resched
> ? __se_sys_swapoff
> ? do_syscall_64
> ? entry_SYSCALL_64_after_hwframe
> 
> As I said, it only occurs occasionally on shutdown. I think it is a safe 
> guess that it can only occur when the swap is not empty, but possibly 
> other conditions are necessary, so I will test further.

Thanks for the update, Alex. I'm looking into a couple of bugs with the
5.1-rc swapoff, but this one doesn't look like anything I know so far.
shmem_recalc_inode() is a surprising place to crash: it's as if the
igrab() in shmem_unuse() were not working. 

Yes, please do send Vineeth and me (or the lists) your low-quality image,
in case we can extract any more info from it; and also please the
disassembly of your kernel's shmem_recalc_inode(), so we can be sure of
exactly what it's crashing on (though I expect that will leave me as
puzzled as before).

If you want to experiment with one of my fixes, not yet written up and
posted, just try changing SWAP_UNUSE_MAX_TRIES in mm/swapfile.c from
3 to INT_MAX: I don't see how that issue could manifest as crashing in
shmem_recalc_inode(), but I may just be too stupid to see it.

Thanks,
Hugh

