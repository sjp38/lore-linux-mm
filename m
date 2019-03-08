Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4D962C43381
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 23:22:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E24D82064A
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 23:22:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="N4IBzFGJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E24D82064A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 69A1A8E0003; Fri,  8 Mar 2019 18:22:02 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6717E8E0002; Fri,  8 Mar 2019 18:22:02 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 512FE8E0003; Fri,  8 Mar 2019 18:22:02 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0D0DF8E0002
	for <linux-mm@kvack.org>; Fri,  8 Mar 2019 18:22:02 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id 134so23853205pfx.21
        for <linux-mm@kvack.org>; Fri, 08 Mar 2019 15:22:02 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=jdPmfLzzP3ok/b81lkslGXd+MZIBpDqUJ4rCASK6E78=;
        b=GfevDtSyHl5CSiQmceGN19jzlF6ZdIU8VYSkfUMB+0gppsmsT22jcWnSAAYMqZCHTp
         QaycaoNZJk26VqG2+LwXF9QUF9+yEbwkLnFw71Wl8TJQpawffk3BifcrWwvSTxITEU3e
         r3OFLWuKXKevZxFj1doz0YD3z4xemIT+HnDHTOxA5fz0pn2o9vt2grhK4mJacbrlOcLx
         yyoXC17kZoR8GZvST1egOAAyNDrQuHjBP+aQRx8xXCY4X3U+0f5gHtdRRV6BJR0LoMMr
         79ia3vF5xpyiLP5HHq8Ys7g0/B2uMNKguO/8/n+k34e5sv6s4uMrnwSjganbcccZmD+k
         ElUw==
X-Gm-Message-State: APjAAAUsT30LFzOtBLuTnipH2iNV6UDns4CXbVuCDAb9vwXjV7Tegjgi
	fQSw/HzdnjhgKpybg1YpidUOrr9BYtabcDHlBlOF72rwn7VOdEio081FiOfwa7fq7KGnN1yIbat
	3PjJAkAJsqMgA/sTr82UDspfZFkJImPfWoav/jj8f0tsIkW2D/8oTCxz/jZcH5NIG1Q==
X-Received: by 2002:a63:4a20:: with SMTP id x32mr19372350pga.429.1552087321362;
        Fri, 08 Mar 2019 15:22:01 -0800 (PST)
X-Google-Smtp-Source: APXvYqzJEyKjzFGCbwVAhxMZLofHjqJqLwahTsZ51qMKULj28tJtwYiJ7aiKMXhmtxXG34BrpGZQ
X-Received: by 2002:a63:4a20:: with SMTP id x32mr19372277pga.429.1552087319850;
        Fri, 08 Mar 2019 15:21:59 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552087319; cv=none;
        d=google.com; s=arc-20160816;
        b=mGSkI6RF4nk9dbyVROfqy9s9h6DQ3pwteKIZ6PvYfyZhD3yyTmo6FMdee1rMGeYdtS
         hMu4nQ2KGT6JJgIQkA1LOmo1LdTl0bUKhY+pjrddZbqpDk8FsFVWXe3k3mtV+OthSjCd
         CfRalrVCyIOTRu2GopLk/Ma1Q5tMh2J5QwriFdtdz9Tulp4MFMnQpPS4pxNw2JFb74JG
         hCC9/qjE8210BTEQlJyaI3ibXdo4YXxU5bqdjeJN0Rj0asA2Sp9GLQeFcIcfB1+I5fhG
         sQnS9qjsY668qt2FHzBdLt8HuM00RHlOTAsSd7d40POKuHi8g5TwV2YVhH5ruTNkdHdc
         EOLQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=jdPmfLzzP3ok/b81lkslGXd+MZIBpDqUJ4rCASK6E78=;
        b=HaR0WmtxQJXpd3hNzc9GIHPQSY2IpVhl0HjLrEDwfYWruB//MoXnNShG0vA0v0qIqh
         dZGRchXViOHndxZp/GR6r6gBiCtitfuiJrSCdYcJ+o0FM2NaG3OF2mXu5GXF9IpQx0mb
         tallFhTRVOxvpUHwAQHenj6tUEx9KC85l+vSQw72Pw37XqVzd8mOftoA//PpBZUua5Ta
         Cel3SlVRSqx+lCZHDeDd2G13HvpwBs7IrXMLS4rWdzyEpLNqlWj87LnVTPyDQXtecFj8
         tB1KmZlQf0otTj/HnWfbxtf7v+SRnZY0exOK3J4tpAVoF0/bhs4cyubGMifCrd3cdnza
         2KLg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=N4IBzFGJ;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id g186si7289236pgc.586.2019.03.08.15.21.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Mar 2019 15:21:59 -0800 (PST)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=N4IBzFGJ;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c82f90d0000>; Fri, 08 Mar 2019 15:21:49 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Fri, 08 Mar 2019 15:21:59 -0800
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Fri, 08 Mar 2019 15:21:59 -0800
Received: from [10.110.48.28] (172.20.13.39) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 8 Mar
 2019 23:21:58 +0000
Subject: Re: [PATCH v4 0/1] mm: introduce put_user_page*(), placeholder
 versions
To: <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>,
	<linux-mm@kvack.org>
CC: Al Viro <viro@zeniv.linux.org.uk>, Christian Benvenuti <benve@cisco.com>,
	Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>,
	Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>, Doug Ledford
	<dledford@redhat.com>, Ira Weiny <ira.weiny@intel.com>, Jan Kara
	<jack@suse.cz>, Jason Gunthorpe <jgg@ziepe.ca>, Jerome Glisse
	<jglisse@redhat.com>, Matthew Wilcox <willy@infradead.org>, Michal Hocko
	<mhocko@kernel.org>, Mike Rapoport <rppt@linux.ibm.com>, Mike Marciniszyn
	<mike.marciniszyn@intel.com>, Ralph Campbell <rcampbell@nvidia.com>, Tom
 Talpey <tom@talpey.com>, LKML <linux-kernel@vger.kernel.org>,
	<linux-fsdevel@vger.kernel.org>
References: <20190308213633.28978-1-jhubbard@nvidia.com>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <4205b2f4-b71e-7fe9-7419-54b0a355b12f@nvidia.com>
Date: Fri, 8 Mar 2019 15:21:58 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.3
MIME-Version: 1.0
In-Reply-To: <20190308213633.28978-1-jhubbard@nvidia.com>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL106.nvidia.com (172.18.146.12) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1552087309; bh=jdPmfLzzP3ok/b81lkslGXd+MZIBpDqUJ4rCASK6E78=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=N4IBzFGJTTH0k6sxMPAyGQlmppTDlNtAOLyacrG2LCWK79btRx439YypA5HRvdTCo
	 sKPYKaUki+bKjJPnp86F3EH5uflAp13/HXg5LJaffMxmI7aFIDfBETJ3Gh+gNrwTwH
	 OrYZ5ftMeISvFUxrbcV6AKfDfcc1TXdhzQLm90tofUXnTMPrzuVbRKsqBryReAg079
	 Vho2lS0zcvo9dZ4paRWEW59ieEZn+Gw/BmD/NaiE1t8mWrYwsg7lUTqLvVMlqUQq4E
	 GV8fal5XnWVl0bHBxAEzPnDyce1TE9cV11430dpZytkAs97KTodZZc9wkrdttdUXry
	 oFcomgQHF2H1A==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/8/19 1:36 PM, john.hubbard@gmail.com wrote:
> From: John Hubbard <jhubbard@nvidia.com>
>=20
> Hi Andrew and all,
>=20
> Can we please apply this (destined for 5.2) once the time is right?
> (I see that -mm just got merged into the main tree today.)
>=20
> We seem to have pretty solid consensus on the concept and details of the
> put_user_pages() approach. Or at least, if we don't, someone please speak
> up now. Christopher Lameter, especially, since you had some concerns
> recently.

I forgot to update the above bit for this v4 patch. In fact, Christopher
already commented on v3. He disagrees that the whole design should be done =
at
all, and it's a high-level point about kernel requirements. I think that
the "we've been supporting this for years" argument needs to prevail,
though, so I'm still pushing this patch for 5.2, and hoping that=20
Christopher eventually agrees.

(The changelog is at the end of this cover letter, btw.)

thanks,
--=20
John Hubbard
NVIDIA

>=20
> Therefore, here is the first patch--only. This allows us to begin
> converting the get_user_pages() call sites to use put_user_page(), instea=
d
> of put_page(). This is in order to implement tracking of get_user_page()
> pages.
>=20
> Normally I'd include a user of this code, but in this case, I think we ha=
ve
> examples of how it will work in the RFC and related discussions [1]. What
> matters more at this point is unblocking the ability to start fixing up
> various subsystems, through git trees other than linux-mm. For example, t=
he
> Infiniband example conversion now needs to pick up some prerequisite
> patches via the RDMA tree. It seems likely that other call sites may need
> similar attention, and so having put_user_pages() available would really
> make this go more quickly.
>=20
> Previous cover letter follows:
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D
>=20
> A discussion of the overall problem is below.
>=20
> As mentioned in patch 0001, the steps are to fix the problem are:
>=20
> 1) Provide put_user_page*() routines, intended to be used
>    for releasing pages that were pinned via get_user_pages*().
>=20
> 2) Convert all of the call sites for get_user_pages*(), to
>    invoke put_user_page*(), instead of put_page(). This involves dozens o=
f
>    call sites, and will take some time.
>=20
> 3) After (2) is complete, use get_user_pages*() and put_user_page*() to
>    implement tracking of these pages. This tracking will be separate from
>    the existing struct page refcounting.
>=20
> 4) Use the tracking and identification of these pages, to implement
>    special handling (especially in writeback paths) when the pages are
>    backed by a filesystem.
>=20
> Overview
> =3D=3D=3D=3D=3D=3D=3D=3D
>=20
> Some kernel components (file systems, device drivers) need to access
> memory that is specified via process virtual address. For a long time, th=
e
> API to achieve that was get_user_pages ("GUP") and its variations. Howeve=
r,
> GUP has critical limitations that have been overlooked; in particular, GU=
P
> does not interact correctly with filesystems in all situations. That mean=
s
> that file-backed memory + GUP is a recipe for potential problems, some of
> which have already occurred in the field.
>=20
> GUP was first introduced for Direct IO (O_DIRECT), allowing filesystem co=
de
> to get the struct page behind a virtual address and to let storage hardwa=
re
> perform a direct copy to or from that page. This is a short-lived access
> pattern, and as such, the window for a concurrent writeback of GUP'd page
> was small enough that there were not (we think) any reported problems.
> Also, userspace was expected to understand and accept that Direct IO was
> not synchronized with memory-mapped access to that data, nor with any
> process address space changes such as munmap(), mremap(), etc.
>=20
> Over the years, more GUP uses have appeared (virtualization, device
> drivers, RDMA) that can keep the pages they get via GUP for a long period
> of time (seconds, minutes, hours, days, ...). This long-term pinning make=
s
> an underlying design problem more obvious.
>=20
> In fact, there are a number of key problems inherent to GUP:
>=20
> Interactions with file systems
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D
>=20
> File systems expect to be able to write back data, both to reclaim pages,
> and for data integrity. Allowing other hardware (NICs, GPUs, etc) to gain
> write access to the file memory pages means that such hardware can dirty
> the pages, without the filesystem being aware. This can, in some cases
> (depending on filesystem, filesystem options, block device, block device
> options, and other variables), lead to data corruption, and also to kerne=
l
> bugs of the form:
>=20
>     kernel BUG at /build/linux-fQ94TU/linux-4.4.0/fs/ext4/inode.c:1899!
>     backtrace:
>         ext4_writepage
>         __writepage
>         write_cache_pages
>         ext4_writepages
>         do_writepages
>         __writeback_single_inode
>         writeback_sb_inodes
>         __writeback_inodes_wb
>         wb_writeback
>         wb_workfn
>         process_one_work
>         worker_thread
>         kthread
>         ret_from_fork
>=20
> ...which is due to the file system asserting that there are still buffer
> heads attached:
>=20
>         ({                                                      \
>                 BUG_ON(!PagePrivate(page));                     \
>                 ((struct buffer_head *)page_private(page));     \
>         })
>=20
> Dave Chinner's description of this is very clear:
>=20
>     "The fundamental issue is that ->page_mkwrite must be called on every
>     write access to a clean file backed page, not just the first one.
>     How long the GUP reference lasts is irrelevant, if the page is clean
>     and you need to dirty it, you must call ->page_mkwrite before it is
>     marked writeable and dirtied. Every. Time."
>=20
> This is just one symptom of the larger design problem: real filesystems
> that actually write to a backing device, do not actually support
> get_user_pages() being called on their pages, and letting hardware write
> directly to those pages--even though that pattern has been going on since
> about 2005 or so.
>=20
>=20
> Long term GUP
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>=20
> Long term GUP is an issue when FOLL_WRITE is specified to GUP (so, a
> writeable mapping is created), and the pages are file-backed. That can le=
ad
> to filesystem corruption. What happens is that when a file-backed page is
> being written back, it is first mapped read-only in all of the CPU page
> tables; the file system then assumes that nobody can write to the page, a=
nd
> that the page content is therefore stable. Unfortunately, the GUP callers
> generally do not monitor changes to the CPU pages tables; they instead
> assume that the following pattern is safe (it's not):
>=20
>     get_user_pages()
>=20
>     Hardware can keep a reference to those pages for a very long time,
>     and write to it at any time. Because "hardware" here means "devices
>     that are not a CPU", this activity occurs without any interaction
>     with the kernel's file system code.
>=20
>     for each page
>         set_page_dirty
>         put_page()
>=20
> In fact, the GUP documentation even recommends that pattern.
>=20
> Anyway, the file system assumes that the page is stable (nothing is writi=
ng
> to the page), and that is a problem: stable page content is necessary for
> many filesystem actions during writeback, such as checksum, encryption,
> RAID striping, etc. Furthermore, filesystem features like COW (copy on
> write) or snapshot also rely on being able to use a new page for as memor=
y
> for that memory range inside the file.
>=20
> Corruption during write back is clearly possible here. To solve that, one
> idea is to identify pages that have active GUP, so that we can use a boun=
ce
> page to write stable data to the filesystem. The filesystem would work
> on the bounce page, while any of the active GUP might write to the
> original page. This would avoid the stable page violation problem, but no=
te
> that it is only part of the overall solution, because other problems
> remain.
>=20
> Other filesystem features that need to replace the page with a new one ca=
n
> be inhibited for pages that are GUP-pinned. This will, however, alter and
> limit some of those filesystem features. The only fix for that would be t=
o
> require GUP users to monitor and respond to CPU page table updates.
> Subsystems such as ODP and HMM do this, for example. This aspect of the
> problem is still under discussion.
>=20
> Direct IO
> =3D=3D=3D=3D=3D=3D=3D=3D=3D
>=20
> Direct IO can cause corruption, if userspace does Direct-IO that writes t=
o
> a range of virtual addresses that are mmap'd to a file.  The pages writte=
n
> to are file-backed pages that can be under write back, while the Direct I=
O
> is taking place.  Here, Direct IO races with a write back: it calls
> GUP before page_mkclean() has replaced the CPU pte with a read-only entry=
.
> The race window is pretty small, which is probably why years have gone by
> before we noticed this problem: Direct IO is generally very quick, and
> tends to finish up before the filesystem gets around to do anything with
> the page contents.  However, it's still a real problem.  The solution is
> to never let GUP return pages that are under write back, but instead,
> force GUP to take a write fault on those pages.  That way, GUP will
> properly synchronize with the active write back.  This does not change th=
e
> required GUP behavior, it just avoids that race.
>=20
> Changes since v3:
>=20
>  * Moved put_user_page*() implementation from swap.c to gup.c, as per
>    Jerome's review recommendation.
>=20
>  * Updated wording in patch #1 (and in this cover letter) to refer to rea=
l
>    filesystems with a backing store, as per Christopher Lameter's feedbac=
k.
>=20
>  * Rebased to latest linux.git: commit 3601fe43e816 ("Merge tag
>    'gpio-v5.1-1' of git://git.kernel.org/pub/scm/linux/kernel/git/linusw/=
linux-gpio")
>=20
> Changes since v2:
>=20
>  * Reduced down to just one patch, in order to avoid dependencies between
>    subsystem git repos.
>=20
>  * Rebased to latest linux.git: commit afe6fe7036c6 ("Merge tag
>    'armsoc-late' of git://git.kernel.org/pub/scm/linux/kernel/git/soc/soc=
")
>=20
>  * Added Ira's review tag, based on
>    https://lore.kernel.org/lkml/20190215002312.GC7512@iweiny-DESK2.sc.int=
el.com/
>=20
>=20
> [1] https://lore.kernel.org/r/20190208075649.3025-3-jhubbard@nvidia.com
>     (RFC v2: mm: gup/dma tracking)
>=20
> Cc: Christian Benvenuti <benve@cisco.com>
> Cc: Christoph Hellwig <hch@infradead.org>
> Cc: Christopher Lameter <cl@linux.com>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Dave Chinner <david@fromorbit.com>
> Cc: Dennis Dalessandro <dennis.dalessandro@intel.com>
> Cc: Doug Ledford <dledford@redhat.com>
> Cc: Ira Weiny <ira.weiny@intel.com>
> Cc: Jan Kara <jack@suse.cz>
> Cc: Jason Gunthorpe <jgg@ziepe.ca>
> Cc: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> Cc: Matthew Wilcox <willy@infradead.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Mike Rapoport <rppt@linux.ibm.com>
> Cc: Mike Marciniszyn <mike.marciniszyn@intel.com>
> Cc: Ralph Campbell <rcampbell@nvidia.com>
> Cc: Tom Talpey <tom@talpey.com>
>=20
> John Hubbard (1):
>   mm: introduce put_user_page*(), placeholder versions
>=20
>  include/linux/mm.h | 24 ++++++++++++++
>  mm/gup.c           | 82 ++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 106 insertions(+)
>=20

