Return-Path: <SRS0=RIH8=R4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B5EFDC43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 15:37:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7A6C82083D
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 15:37:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7A6C82083D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0567C6B0003; Mon, 25 Mar 2019 11:37:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 004F76B0006; Mon, 25 Mar 2019 11:37:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E36806B0007; Mon, 25 Mar 2019 11:37:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id C14E86B0003
	for <linux-mm@kvack.org>; Mon, 25 Mar 2019 11:37:26 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id q21so10549055qtf.10
        for <linux-mm@kvack.org>; Mon, 25 Mar 2019 08:37:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to;
        bh=ULt4UAznv66zNgUvqi5PYm74n/6JzDtsJmpKbhGf0Hc=;
        b=KnGbA4zU72WqL4VXzcpSaVLsp9GF1Af2ZlTkkk8mN46F7IM0YOpOrlA7nDOjfXADUf
         FW3LG4AnTvvtZu+frHL3WSXHlz/rfbHSsQEL0l99UJB3AcArVE0WTqP4of7+dC5zFZnI
         Hvo7BvGz+tNvihlwLRiyJqw0LoFscP5DY44u8wHk8G4KxIElZmb/2nbhXXF+BX9iw2lz
         5TRMZ0n6FGW3njxsxp/aa6lwNwiVLHteRkDy8kiE7dAQ2P3JBDP40SEBQngo2fVZ98g0
         ULwKCkeeaQDwtzGUIVJL+apigczZyNHbK2ONgi3eXAnU6XM64nM2lRSF+sjk8E8LBWtB
         r/2w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWq5cspuTKuCZniH3mwakfl7VFXCOwRDdSfWntsQYvFs4+uw56z
	RZVgAUG23u5cUcq5tGl13Y3LnTgi/h1xeCtAz4iol3umQVRpaJy4ppFdAxzx+Bf3X+9Lfr/fgKq
	0M8IHFaZZHLajzgClP/76GiEkkQNAIPj6PLT/Po3ybWloYDzEaQ/VH0EoMcZiXbeYhQ==
X-Received: by 2002:a0c:ba13:: with SMTP id w19mr19876238qvf.179.1553528246542;
        Mon, 25 Mar 2019 08:37:26 -0700 (PDT)
X-Received: by 2002:a0c:ba13:: with SMTP id w19mr19876187qvf.179.1553528245658;
        Mon, 25 Mar 2019 08:37:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553528245; cv=none;
        d=google.com; s=arc-20160816;
        b=q8rNL0phgxL/NtFkLpPSCiZzdY/BsYEv0TgzbGv3X4rccAM/WLht5ordAolxTnLmav
         dGYzyrNP6MLzGju4zkWRvopk18sodvI7ebF286t7vtARjAOavmq3uXNN0cNzTcTnB16G
         RZuqZj7ZXel48QbrCcR0bwX0YaG8wSewjoTrNA9orzAL0Rbi1hCD9zEEMT99efKjZoUs
         UT7LJjGNz/BnYjOduRRhut5iYrJMpOJkPCurIkkVAUCE8eIB4f44WAourEO6Cuzx3hj8
         QpAM1aLWYTpo46qOCqPMypPqANgJkTEfctNJBLpUhAZhY0OzJZqvccu/VpZalrbBp6hg
         RdcQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-transfer-encoding:content-disposition
         :mime-version:references:message-id:subject:cc:to:from:date;
        bh=ULt4UAznv66zNgUvqi5PYm74n/6JzDtsJmpKbhGf0Hc=;
        b=WB3+bYB6IO6mkijvXhA/QOPph8LfO4RE230tG3l1i6H2Nn3bCg9wNYS4QRCkfWuNoC
         bmjvKZLhkEwTYoIKClXYcGw5D3qukeyoErAqE8NCJXTExujJqPNgfuTwUxMpS8phbvF9
         UtxPwx20j3pNA59NZ3LvXRUm1et8m1R2TcHd0M2zj+m14ceasyOLxTKjWeae62DYd+T6
         ytF/LacGbIFNrFuVy8uDCzTLnruuAaHtJE127fL2vb/DtwEXTo5+HIcIqw1/tTpqjJMb
         LpP2ASHMP66HPnAlDE4/f/xlfNW0m3bjRPOIMf3tg8pXYtfMnI7lPFovH+KIJLJ6Jmx3
         jFMw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v186sor11304948qka.27.2019.03.25.08.37.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Mar 2019 08:37:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqzEUyn4wi4Muptc2YOpiuM7Xps1sZy26/sOBF6ZgKXmq1Rh2mOG+RfvwzCK/Bg9K1n8TZ90Nw==
X-Received: by 2002:a37:4dc5:: with SMTP id a188mr19611207qkb.181.1553528245451;
        Mon, 25 Mar 2019 08:37:25 -0700 (PDT)
Received: from redhat.com (pool-173-76-246-42.bstnma.fios.verizon.net. [173.76.246.42])
        by smtp.gmail.com with ESMTPSA id p188sm9361806qkb.43.2019.03.25.08.37.23
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 25 Mar 2019 08:37:24 -0700 (PDT)
Date: Mon, 25 Mar 2019 11:37:22 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Nitesh Narayan Lal <nitesh@redhat.com>
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	David Hildenbrand <david@redhat.com>,
	kvm list <kvm@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
	linux-mm <linux-mm@kvack.org>, Paolo Bonzini <pbonzini@redhat.com>,
	lcapitulino@redhat.com, pagupta@redhat.com, wei.w.wang@intel.com,
	Yang Zhang <yang.zhang.wz@gmail.com>,
	Rik van Riel <riel@surriel.com>, dodgen@google.com,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, dhildenb@redhat.com,
	Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC][Patch v9 0/6] KVM: Guest Free Page Hinting
Message-ID: <20190325113543-mutt-send-email-mst@kernel.org>
References: <20190306130955-mutt-send-email-mst@kernel.org>
 <ce55943e-87b6-c102-9827-2cfd45b7192c@redhat.com>
 <CAKgT0UcGCFNQRZFmp8oMkG+wKzRtwN292vtFWgyLsdyRnO04gQ@mail.gmail.com>
 <ed9f7c2e-a7e3-a990-bcc3-459e4f2b4a44@redhat.com>
 <4bd54f8b-3e9a-3493-40be-668962282431@redhat.com>
 <6d744ed6-9c1c-b29f-aa32-d38387187b74@redhat.com>
 <CAKgT0UcBDKr0ACHQWUCvmm8atxM6wSu7aCRFJkFvfjT_W_femQ@mail.gmail.com>
 <6709bb82-5e99-019d-7de0-3fded385b9ac@redhat.com>
 <6ab9b763-ac90-b3db-3712-79a20c949d5d@redhat.com>
 <99b9fa88-17b1-f2a9-7dd4-7a8f6e790d30@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <99b9fa88-17b1-f2a9-7dd4-7a8f6e790d30@redhat.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 25, 2019 at 10:27:46AM -0400, Nitesh Narayan Lal wrote:
> I performed some experiments to see if the current implementation of
> hinting breaks THP. I used AnonHugePages to track the THP pages
> currently in use and memhog as the guest workload.
> Setup:
> Host Size: 30GB (No swap)
> Guest Size: 15GB
> THP Size: 2MB
> Process: Guest is installed with different kernels to hint different
> granularities(MAX_ORDER - 1, MAX_ORDER - 2 and MAX_ORDER - 3). Memhog 
> 15G is run multiple times in the same guest to see AnonHugePages usage
> in the host.
> 
> Observation:
> There is no THP split for order MAX_ORDER - 1 & MAX_ORDER - 2 whereas
> for hinting granularity MAX_ORDER - 3 THP does split irrespective of
> MADVISE_FREE or MADVISE_DONTNEED.
> -- 
> Regards
> Nitesh
> 

This is on x86 right? So THP is 2M and MAX_ORDER is 8M.
MAX_ORDER - 3 ==> 1M.
Seems to work out.

-- 
MST

