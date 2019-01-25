Return-Path: <SRS0=o7Ai=QB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1584DC282C6
	for <linux-mm@archiver.kernel.org>; Fri, 25 Jan 2019 08:39:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A373320870
	for <linux-mm@archiver.kernel.org>; Fri, 25 Jan 2019 08:39:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="PlL+sttb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A373320870
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1BCF18E00C9; Fri, 25 Jan 2019 03:39:34 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 16D458E00C8; Fri, 25 Jan 2019 03:39:34 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 084498E00C9; Fri, 25 Jan 2019 03:39:34 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id CBEF58E00C8
	for <linux-mm@kvack.org>; Fri, 25 Jan 2019 03:39:33 -0500 (EST)
Received: by mail-yw1-f70.google.com with SMTP id i2so4654204ywb.1
        for <linux-mm@kvack.org>; Fri, 25 Jan 2019 00:39:33 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=5RsQ+sFYoypryxcf4obw0Tm6Js/KH0eBEE767zFLd7g=;
        b=L/MI9B6R1zhR78wX+3ZxLp+ZqbDHfIw5ZmayADXxVkrHhY/SnIdcWfpiM4kzt2wmQg
         j30l7urBakx9/1vuqWPNfWmh4OoHBRsBWlQTGPfnfWVEaVWLsZ7f5mJsV17l/nc804Uu
         dg1kxTEaNBXSu105NaipwT0FIRmykPXGF20ly4BQFXOEpNQ244valIYfYKlCDtWSet/E
         z6i4X6mCyws+56bX2N/WFB3YD8ucL9qVgFz83HqXF7OMkdab5tzVenLG/vvQr0UwF+I5
         2sxt2LcJQoXhiire7pYws2YrMr8w7bUvDH82l07+lnbYpuZUlDdTEeXagih4ZccwN8tb
         46fg==
X-Gm-Message-State: AJcUukc9TCkjYzT7xpmIeLlmRmgA69nO0oqAofy8d2pxSda1wdwKx4jW
	HhnfH2r6VZ/cfXuDc5nRWgROltVs5qixq+5LIC/ZAve5PO28+ubFzOWLEiZqMkkA2pf64gQ19wW
	fud92ECgkOi5/pHJ0FyqgzOYpkfHULafh31vf7PASnBeTOc2l3MhhApLMDwU/9SDO1od+k4J04c
	M1F2SEsCLA0G9fkLJIWHa3f3L1wRGx8x15spRtiMUCA0UtDTjfRv4hIgfJkKsQKIvsHxMIMJHIC
	njF5EW/93SXI1wjGPOe1mq2Gthm56aSGfcVtNS3CFgRphi7iXl1aLKXFGjWIVyBHH5KPSKDFmJr
	C+/kPVNgrNBYCIPEWzP6qEhVxQkhnTZaJ6SUKlH4dSmOLYo0Hxk2OTHExt1/c4IEbxJiFIkBFQR
	q
X-Received: by 2002:a81:99d6:: with SMTP id q205mr9915577ywg.106.1548405573448;
        Fri, 25 Jan 2019 00:39:33 -0800 (PST)
X-Received: by 2002:a81:99d6:: with SMTP id q205mr9915545ywg.106.1548405572648;
        Fri, 25 Jan 2019 00:39:32 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548405572; cv=none;
        d=google.com; s=arc-20160816;
        b=VgvcHsiN+wOod+TJzqparsQglUKVOAlYuYbH4WxHoqcPuCKS0QaJxDGbfp78chBM0A
         IeWw2so/yU+yElzK3JpzHnzqJY0zFzDt4hFmY/MTp26EzmOWmkKRqcU7IoEsg4TFtjaX
         PMfbAZvb0uxyjzlx3v+qDD886a1hOuPVZ6bwM6/P7oqd0E6nme9s4yRXNc9/tRx9aJYZ
         vRwjU7BeknXYLctCdhZ0uIrUpvE0lUgYlGp06SwgV5Ut46T+PxlErVPa6QfZLYm0zQ6c
         ih0hi3hSYqMH8HXvydQC25l/PNxIF4rSacULwf28wNIDFO1auxBPFR2cifm28ttiWzXL
         6UXQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=5RsQ+sFYoypryxcf4obw0Tm6Js/KH0eBEE767zFLd7g=;
        b=WFYBMhBBgwrUDNes4GC6KiKDjPCExO6iApAMcuN9lKN66fZ5oDWfN4VY4dr/V+86/L
         fGanoz/+SHwjvVdMsblI0X7P53nq5OrS6KzRRqvE7e0UYEfvdwQtJiJwPvTGQCntga85
         5IUC6+Xt/JXUWtUyUWp8bTZYzLEf/1z6Ct8CkEi/3/BN5fk2LCW5A4BxrZn1AvzTQu46
         Jw/Ba/m76ywuuTER9W11ZbTM/sJQSTkTRGDoG/qWWN6kP+iEwvh0bkJtQycs32FiY2Pu
         l52MS/mYQkusZYweE0StlsgljbLYlwesn0GHGlTVZ0oH4kHQIbny9Hr75EoKEPMPYHx5
         m37A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=PlL+sttb;
       spf=pass (google.com: domain of amir73il@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=amir73il@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id x125sor10816529ybx.117.2019.01.25.00.39.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 25 Jan 2019 00:39:32 -0800 (PST)
Received-SPF: pass (google.com: domain of amir73il@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=PlL+sttb;
       spf=pass (google.com: domain of amir73il@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=amir73il@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=5RsQ+sFYoypryxcf4obw0Tm6Js/KH0eBEE767zFLd7g=;
        b=PlL+sttbW4npqEKLdlyhPvsMD6YFCG43bBnF9L7lYY6xEfllLL7EuMU8bJk7wNMaGz
         Nodr8t/eCCaISzrEp4VOevg289FxomMNDAdzAkHH6VQI9VUSjZA9JH+e/9xAT5nzPNCg
         o6CiEEgSv0HhkEXHwR5ZoXc7sgZXL0ookJbSPHNgKqDJ+KKNDSc65na+NnLrh2wxyDmQ
         XHFq7Gd8YOfYYRdvrMjCZAd/PGa21mU2K0mYISt7nlDi0tWnjGySlGbeVhuBPJltvvvg
         eURLtMSnLCkZmTwQos3QRaYwSQ8//L73iuZ7D53tgPtiGqwsc+YTxnn16FxB4Do792+m
         wCGw==
X-Google-Smtp-Source: ALg8bN5oi4uxQ4df1M2elZHI/C91sqzV6u81+gFs4I1wMlB9wTl+P9BzIpnS5a0+bQocgYVONBoX4pp/P4M4pWP1vcQ=
X-Received: by 2002:a25:f81d:: with SMTP id u29mr9920972ybd.397.1548405572087;
 Fri, 25 Jan 2019 00:39:32 -0800 (PST)
MIME-Version: 1.0
References: <CAOQ4uxj4DiU=vFqHCuaHQ=4XVkTeJrXci0Y6YUX=22dE+iygqA@mail.gmail.com>
 <20190123145434.GK13149@quack2.suse.cz> <20190124103906.iwbttyrf6lddieou@kshutemo-mobl1>
In-Reply-To: <20190124103906.iwbttyrf6lddieou@kshutemo-mobl1>
From: Amir Goldstein <amir73il@gmail.com>
Date: Fri, 25 Jan 2019 10:39:20 +0200
Message-ID:
 <CAOQ4uxgfkzWsh+=gKGL4YGiBGLYvhcOCy13X5L2ycVdghYhrOA@mail.gmail.com>
Subject: Re: [LSF/MM TOPIC] Sharing file backed pages
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Jerome Glisse <jglisse@redhat.com>, Jan Kara <jack@suse.cz>
Cc: lsf-pc@lists.linux-foundation.org, Al Viro <viro@zeniv.linux.org.uk>, 
	"Darrick J. Wong" <darrick.wong@oracle.com>, Dave Chinner <david@fromorbit.com>, 
	Matthew Wilcox <willy@infradead.org>, Chris Mason <clm@fb.com>, Miklos Szeredi <miklos@szeredi.hu>, 
	linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190125083920.yNU1oi9otgl_vtbyNocm2V9QbYu87wlo7RP3EXdEZXE@z>

On Thu, Jan 24, 2019 at 12:39 PM Kirill A. Shutemov
<kirill@shutemov.name> wrote:
>
> On Wed, Jan 23, 2019 at 03:54:34PM +0100, Jan Kara wrote:
> > On Wed 23-01-19 10:48:58, Amir Goldstein wrote:
> > > In his session about "reflink" in LSF/MM 2016 [1], Darrick Wong brought
> > > up the subject of sharing pages between cloned files and the general vibe
> > > in room was that it could be done.
> > >
> > > In his talk about XFS subvolumes and snapshots [2], Dave Chinner said
> > > that Matthew Willcox was "working on that problem".
> > >
> > > I have started working on a new overlayfs address space implementation
> > > that could also benefit from being able to share pages even for filesystems
> > > that do not support clones (for copy up anticipation state).
> > >
> > > To simplify the problem, we can start with sharing only uptodate clean
> > > pages that map the same offset in respected files. While the same offset
> > > requirement somewhat limits the use cases that benefit from shared file
> > > pages, there is still a vast majority of use cases (i.e. clone full
> > > image), where sharing pages of similar offset will bring a lot of
> > > benefit.
> > >
> > > At first glance, this requires dropping the assumption that a for an
> > > uptodate clean page, vmf->vma->vm_file->f_inode == page->mapping->host.
> > > Is there really such an assumption in common vfs/mm code?  and what will
> > > it take to drop it?
> >
> > There definitely is such assumption. Take for example page reclaim as one
> > such place that will be non-trivial to deal with. You need to remove the
> > page from page cache of all inodes that contain it without having any file
> > context whatsoever. So you will need to create some way for this page->page
> > caches mapping to happen.
>
> We have it solved for anon pages where we need to find all VMA the page
> might be mapped to. I think we should look into adopting anon_vma
> approach[1] for files too. From the first look the problemspace looks very
> similar.
>

Yes there are many similarities and we should definitely adopt existing
solutions for shared anon pages. There are also differences and we need
to make sure we cover them in the design.

For example, reclaiming a multiply shared page may prove to be more
expensive then reclaiming a non shared page. Depending on how the page
has ended up being shared (perhaps by KSM or by a special copy_file_range()
mode on an fs that doesn't support clone_file_range), the next time
the instances
of the shared page are faulted in, they may not be shared anymore and may
consume more cache space.

I'd also like to discuss which control the filesystem gets over
unsharing a page.
Will fs have a say before page is COWed? By which order of VMAs?
I think most people currently view the shared pages concept as symetric for
all VMAs that share the page, but for overlayfs, a "master-slave" or "stacked"
model might be a better fit, so that, for example, "master" can make a call to
notify the "slave" about page being dirty instead of breaking the sharing.

Jerome,

Do you think we will have time to cover these issues in the joint session.
Perhaps we should tentatively plan for a filesystem track session for
filesystem followup issues?

Some issues I can think of are:
- Which control filesystem gets for new functionality (see above)
- Common code to help sharing pages, i.e. for generic vfs interfaces
  like clone/dedupe/copy_range
- Can/should blockdev pages (of same block) be shared with file
  pages of the filesystem on that blockdev by common mpage_ helpers?
- A common use case is that filesystem images are cloned and loop mounted.
  How can we propagate the knowledge about files data on loop mounted fs
  originating from the same underlying block though the loop device? (*)

(*) loop device is just a simple example, but same can apply to other
storage stacks as well where block layer has dedupe.

Thanks,
Amir.

