Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0EFFFC43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 03:50:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B89E32087C
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 03:50:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B89E32087C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3D2228E0003; Mon, 11 Mar 2019 23:50:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 381448E0002; Mon, 11 Mar 2019 23:50:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2705C8E0003; Mon, 11 Mar 2019 23:50:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id EE59D8E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 23:50:52 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id f70so1132290qke.8
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 20:50:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to;
        bh=QRPDOmP3PZybh4jg1T0rjd7mcth50LuMLbslo/IWnIE=;
        b=QGboA1Ag5anDICbV/+pTrH/huIm9+DmarrOEy249Wlv5biTFwtnLQb7tecu+YWixRx
         Nxbo+GSZGrm9lsULkENRQ4UPmPG56BRBjcVzPXrdjyeOXvjK3TqMsn6AhjaB79Tlfh7A
         CLZhjpljdz9+Gs60AzWEz0KMbE03CsG0sTEeaA2NbRILz5f7nSADbc3U7vUTvZRjcr1C
         BBXSrjPbXIpWfD6TJclZsYt9nVu1r9zkt7R42ehCgY5TSbzybodeb8CMPQZLmUV/MP7Z
         DmgVz3gZoLcoXjkfOV8KcLLIDhlcutHwteyHW1cso5Xy57qmnjLimmkO914NtfXe/92y
         bp8w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWN6Aa9CmQQsKh4uf8hfy0SS/fhIWa5Y2XKDkcHsNQZJKJQYb/q
	BauoTa9nLMxnh6ueu5aIcyVvXlelFLi+axETXjVaoN1O87sLEcIMN05hKphAy5nGQtAe7gG1ivk
	UZpmNR/nPqtqfdjJu0Agy4E8ZPoj2YWispgMAynGP+2lJ17MpeIBfe3n2IZKTyRV2ZUatmFzkyJ
	rARHyThcLJRkND0n77qYC5kWshW6HXhm8iI/QE96D9GaSX1u3Q2gv0rqD64O5oEs6l6qCscJyN8
	pCCaubdQDamSiB+5gKY/Kh9ZzMNhnCQRZ/Osvb8kT8q8MCWiVtzZK7xKhWV7L0P4Bnct5WRrNl8
	WW8nHABW6i3E3B/dTbvTG39gqzyJpGmAhgnbm9k4z07togu0WB15BUZEVimN7mrl6Qx0u8GmIQ5
	H
X-Received: by 2002:ac8:111a:: with SMTP id c26mr12113387qtj.309.1552362652735;
        Mon, 11 Mar 2019 20:50:52 -0700 (PDT)
X-Received: by 2002:ac8:111a:: with SMTP id c26mr12113364qtj.309.1552362651850;
        Mon, 11 Mar 2019 20:50:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552362651; cv=none;
        d=google.com; s=arc-20160816;
        b=KOiHebxd6hlLBALuKe8t5yfXh+uUXz7qFn6CrWfxPFY+Nr9LTd6Kb+hBcY1en5gWEF
         PCYvrcROCcKQpw4Ou9nZRxYJIoPVGA0JUeg6k+DCFnFSb9UwE85L1NIT49IppJUyXuto
         eP8mePN16bLWXaC9VblwjXOD5s6OJX7kpEj3salzfJ4KapoWOsRE1DYGgHvemkbcebBL
         I95QHqSJbt5nAAsn8B4PlFAW1eYvstvSl/rQozlJcDGllJ1FiMHi40y2NuqPaqaxnPGa
         4jgzX8FVOeg4CKSxCB4p85LQhzHCx094SrIvRhbSetuSIvat4a3+ajFxmcj3quPEKYHc
         cn0A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-transfer-encoding:content-disposition
         :mime-version:references:message-id:subject:cc:to:from:date;
        bh=QRPDOmP3PZybh4jg1T0rjd7mcth50LuMLbslo/IWnIE=;
        b=D6WaA4yJwnkYps9nCz7TWsQ3oEFF48WUXDgHboYpKxvU7Wf+lh0xUPND0dcUMXgj15
         m8T7hP1GjtHJcU6exVcPVbvN4bP5YTDxveRVGzljdQTqDu6Bgxci0kTbnEnujcLJknMm
         3dvGB62pGFHDCdsJQ1O3Anh5GZobJWLd5b1tcf5fBAinfSZN4BDJLQRHntZViMHJBc1e
         vo1ZrZlMlV6/+PXqIIprg/IBOu5i/ikw7pQOkKfH8SuTvlMgTVJh/g5+vy4z5TcKqX84
         PaeP79WEEaiiZm0gfdqYx61GZ9SPN89xKTmvbC6OYh+XknFvl4HKvKTI8HgfDVbF3B4K
         /MMg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h22sor9046286qtc.28.2019.03.11.20.50.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Mar 2019 20:50:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqytPBLiV9ui85yEFwzYki+uAt4jj2vFWUzeaP5nba2eYldaAweFOnQcfmd69Ncni6yOLzzxow==
X-Received: by 2002:ac8:faf:: with SMTP id b44mr28675567qtk.9.1552362651332;
        Mon, 11 Mar 2019 20:50:51 -0700 (PDT)
Received: from redhat.com (pool-173-76-246-42.bstnma.fios.verizon.net. [173.76.246.42])
        by smtp.gmail.com with ESMTPSA id p35sm5014288qte.83.2019.03.11.20.50.49
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Mar 2019 20:50:50 -0700 (PDT)
Date: Mon, 11 Mar 2019 23:50:47 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Jason Wang <jasowang@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, peterx@redhat.com, linux-mm@kvack.org,
	Jerome Glisse <jglisse@redhat.com>
Subject: Re: [RFC PATCH V2 5/5] vhost: access vq metadata through kernel
 virtual address
Message-ID: <20190311234956-mutt-send-email-mst@kernel.org>
References: <1551856692-3384-1-git-send-email-jasowang@redhat.com>
 <1551856692-3384-6-git-send-email-jasowang@redhat.com>
 <20190307103503-mutt-send-email-mst@kernel.org>
 <20190307124700-mutt-send-email-mst@kernel.org>
 <20190307191622.GP23850@redhat.com>
 <e2fad6ed-9257-b53c-394b-bc913fc444c0@redhat.com>
 <20190308194845.GC26923@redhat.com>
 <8b68a2a0-907a-15f5-a07f-fc5b53d7ea19@redhat.com>
 <20190311084525-mutt-send-email-mst@kernel.org>
 <ff45ea43-1145-5ea6-767c-1a99d55a9c61@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <ff45ea43-1145-5ea6-767c-1a99d55a9c61@redhat.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 12, 2019 at 10:52:15AM +0800, Jason Wang wrote:
> 
> On 2019/3/11 下午8:48, Michael S. Tsirkin wrote:
> > On Mon, Mar 11, 2019 at 03:40:31PM +0800, Jason Wang wrote:
> > > On 2019/3/9 上午3:48, Andrea Arcangeli wrote:
> > > > Hello Jeson,
> > > > 
> > > > On Fri, Mar 08, 2019 at 04:50:36PM +0800, Jason Wang wrote:
> > > > > Just to make sure I understand here. For boosting through huge TLB, do
> > > > > you mean we can do that in the future (e.g by mapping more userspace
> > > > > pages to kenrel) or it can be done by this series (only about three 4K
> > > > > pages were vmapped per virtqueue)?
> > > > When I answered about the advantages of mmu notifier and I mentioned
> > > > guaranteed 2m/gigapages where available, I overlooked the detail you
> > > > were using vmap instead of kmap. So with vmap you're actually doing
> > > > the opposite, it slows down the access because it will always use a 4k
> > > > TLB even if QEMU runs on THP or gigapages hugetlbfs.
> > > > 
> > > > If there's just one page (or a few pages) in each vmap there's no need
> > > > of vmap, the linearity vmap provides doesn't pay off in such
> > > > case.
> > > > 
> > > > So likely there's further room for improvement here that you can
> > > > achieve in the current series by just dropping vmap/vunmap.
> > > > 
> > > > You can just use kmap (or kmap_atomic if you're in preemptible
> > > > section, should work from bh/irq).
> > > > 
> > > > In short the mmu notifier to invalidate only sets a "struct page *
> > > > userringpage" pointer to NULL without calls to vunmap.
> > > > 
> > > > In all cases immediately after gup_fast returns you can always call
> > > > put_page immediately (which explains why I'd like an option to drop
> > > > FOLL_GET from gup_fast to speed it up).
> > > > 
> > > > Then you can check the sequence_counter and inc/dec counter increased
> > > > by _start/_end. That will tell you if the page you got and you called
> > > > put_page to immediately unpin it or even to free it, cannot go away
> > > > under you until the invalidate is called.
> > > > 
> > > > If sequence counters and counter tells that gup_fast raced with anyt
> > > > mmu notifier invalidate you can just repeat gup_fast. Otherwise you're
> > > > done, the page cannot go away under you, the host virtual to host
> > > > physical mapping cannot change either. And the page is not pinned
> > > > either. So you can just set the "struct page * userringpage = page"
> > > > where "page" was the one setup by gup_fast.
> > > > 
> > > > When later the invalidate runs, you can just call set_page_dirty if
> > > > gup_fast was called with "write = 1" and then you clear the pointer
> > > > "userringpage = NULL".
> > > > 
> > > > When you need to read/write to the memory
> > > > kmap/kmap_atomic(userringpage) should work.
> > > Yes, I've considered kmap() from the start. The reason I don't do that is
> > > large virtqueue may need more than one page so VA might not be contiguous.
> > > But this is probably not a big issue which just need more tricks in the
> > > vhost memory accessors.
> > > 
> > > 
> > > > In short because there's no hardware involvement here, the established
> > > > mapping is just the pointer to the page, there is no need of setting
> > > > up any pagetables or to do any TLB flushes (except on 32bit archs if
> > > > the page is above the direct mapping but it never happens on 64bit
> > > > archs).
> > > I see, I believe we don't care much about the performance of 32bit archs (or
> > > we can just fallback to copy_to_user() friends).
> > Using copyXuser is better I guess.
> 
> 
> Ok.
> 
> 
> > 
> > > Using direct mapping (I
> > > guess kernel will always try hugepage for that?) should be better and we can
> > > even use it for the data transfer not only for the metadata.
> > > 
> > > Thanks
> > We can't really. The big issue is get user pages. Doing that on data
> > path will be slower than copyXuser.
> 
> 
> I meant if we can find a way to avoid doing gup in datapath. E.g vhost
> maintain a range tree and add or remove ranges through MMU notifier. Then in
> datapath, if we find the range, then use direct mapping otherwise
> copy_to_user().
> 
> Thanks

We can try. But I'm not sure there's any reason to think there's any
locality there.

> 
> >   Or maybe it won't with the
> > amount of mitigations spread around. Go ahead and try.
> > 
> > 

