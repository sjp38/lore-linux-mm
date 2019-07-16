Return-Path: <SRS0=rp0W=VN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9977BC76195
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 22:00:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 54B2721841
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 22:00:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="XSWiZuBk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 54B2721841
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DCAEB6B0003; Tue, 16 Jul 2019 18:00:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D54F66B0005; Tue, 16 Jul 2019 18:00:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BCD678E0001; Tue, 16 Jul 2019 18:00:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 827146B0003
	for <linux-mm@kvack.org>; Tue, 16 Jul 2019 18:00:50 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id 65so10861995plf.16
        for <linux-mm@kvack.org>; Tue, 16 Jul 2019 15:00:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=C7EAvIzJhfw3NRpeGOT4pyiQDG/JNI/dfZ3JbrT81Hg=;
        b=tUICCHDSf5ccLFf4KnxfB2YJ10tuSFpA+QgvVy1b4GF00TSCbIw0gWIRFfNOPIJdVW
         bGdCgR4q3bBv297Vhj3DxGKcuIuTl7DYbuulIY+v75gTxdmu9jOb80mCczPdYhBKAZkE
         75Mxc5zhA79q2u3YGco1WCNiAoiYbPf78vs6GUxqrPMmPp1dwrfarAv0tJU/g6HC6yCO
         1ULt7Xy+tMLeXgF/9stdDZ9XMC0XvVqZLsaomnJ2xDvPKcx5Ki5tcbo0lcGm4j5NKaHU
         Ztd1qwbw2ap+wW+6tJ4zI+bGzaRCbjge8VKQqFrL/0PiS8PBCXC1Z5NYXgpzdm93lN5Y
         VjWQ==
X-Gm-Message-State: APjAAAWUw9V/CeDJEOujdWR3FXefrqZxmScuWs2cutCQBXDt/xI/X2oa
	emYs5ujFitdCVpAmsOyDY8FsK+uKWsZHGiclVUh9fQKvF9Xr4Vc/gtoXU8yLKYOLea+fJhNB+J4
	0mUXm65AOjBXMmWsdhD6VsxsNPhbhXuHBFgSECmqN8WRB3nCVDYjSFZms2uuwaSLaGw==
X-Received: by 2002:a17:902:1003:: with SMTP id b3mr39147182pla.172.1563314450155;
        Tue, 16 Jul 2019 15:00:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx3ARXUEseDfF5SOEbk8VorQCzh4mYwaJx65/6w5NYBI2jdtmUoSKB7wXyw25zOoLocM4Ho
X-Received: by 2002:a17:902:1003:: with SMTP id b3mr39147117pla.172.1563314449256;
        Tue, 16 Jul 2019 15:00:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563314449; cv=none;
        d=google.com; s=arc-20160816;
        b=PI4GPQxcKTg7XBbx9TZBiwmcHqgVO2eG2Nqg81II8OgOzAW1O5COLTY0ozMPgcn0gC
         n5WYm4c/rPPjDnSMc3RdFp0mSnzvSi/usWaRY9zQcBmf/b342scRncxAksk/ufQjaYo4
         WnuAlxcwqSEqeMCkLNsiwvLg6Qpr3Zl4X9eCnlv6Jn6z0f2TCCM4ySU1C+sCI3Ig3ule
         oZ5gYUxAEQz2zMvvdI72OpdcBP2NERFkioQ+of0d9QZOcREoOaY/NZw6uMmwpxkkWlQQ
         mUfTL+wZYKTSzjEAuie8hWYniQizIfeBM+dDcA3Wz93SdpHQhO85QxZdQ06hS7BTUd1E
         xXdQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=C7EAvIzJhfw3NRpeGOT4pyiQDG/JNI/dfZ3JbrT81Hg=;
        b=l0VW+9DcwxgBQEZT+PrNruQwQ6tyeFHPM4MfqCAjBHbklCdgyy2ZR9/vP/pOmzO02d
         4GYLMZy/ZpiFOq+WZNYeItJ9BVlRGo+wY1VnpRWp/7QlP5aN41rnQ8AoPNBKNV+nBvzN
         OB5SDYlytERZeF1hZ5mOP6M5jxxmESShZhTsFPlFa6FDfiQWlLqfAE1jQxuz2ZAgbqzy
         gwVl5YjP2v2dGp7nEQnYMeTvJ8qeYYLv1AQGnFjJ2c6f7N6yKhMt33HXCj1N+bJ71Aah
         s6GwBvWqt/1gQrjRUN4IJ+j1XkENtX9U7Frc+51CWhfA8W16SDmKJ2byWZzSAvMbiLj6
         zcTg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=XSWiZuBk;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id z190si22185024pgd.303.2019.07.16.15.00.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jul 2019 15:00:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=XSWiZuBk;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.64])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 459DC217D9;
	Tue, 16 Jul 2019 22:00:48 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1563314448;
	bh=MZiI+dn9mTuyzIwRcV9Xmn9Ls3mvI60j/scPusuitoY=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=XSWiZuBkMQon8Lef5PmzojoSZZ9fRe2jegeNSZnEenhkD8cdTCQlE6EJpSJoBqgjy
	 wUCAz9PwWcsuoV7ZdQqEhoN9Mox91kVFBCk9L9u6wGxpu+qMlGIrkxCGHu/x3UMAnl
	 J8ebYbD6PKGFHh6l70c9iZEJlyazzO5W9LuTVRLw=
Date: Tue, 16 Jul 2019 15:00:47 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Nadav Amit <namit@vmware.com>
Cc: Dan Williams <dan.j.williams@intel.com>, Linux Kernel Mailing List
 <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Borislav
 Petkov <bp@suse.de>, Toshi Kani <toshi.kani@hpe.com>, Peter Zijlstra
 <peterz@infradead.org>, Dave Hansen <dave.hansen@linux.intel.com>, Bjorn
 Helgaas <bhelgaas@google.com>, Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 0/3] resource: find_next_iomem_res() improvements
Message-Id: <20190716150047.3c13945decc052c077e9ee1e@linux-foundation.org>
In-Reply-To: <19C3DCA0-823E-46CB-A758-D5F82C5FA3C8@vmware.com>
References: <20190613045903.4922-1-namit@vmware.com>
	<CAPcyv4hpWg5DWRhazS-ftyghiZP-J_M-7Vd5tiUd5UKONOib8g@mail.gmail.com>
	<9387A285-B768-4B58-B91B-61B70D964E6E@vmware.com>
	<CAPcyv4hstt+0teXPtAq2nwFQaNb9TujgetgWPVMOnYH8JwqGeA@mail.gmail.com>
	<19C3DCA0-823E-46CB-A758-D5F82C5FA3C8@vmware.com>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 18 Jun 2019 21:56:43 +0000 Nadav Amit <namit@vmware.com> wrote:

> > ...and is constant for the life of the device and all subsequent mappings.
> > 
> >> Perhaps you want to cache the cachability-mode in vma->vm_page_prot (which I
> >> see being done in quite a few cases), but I don’t know the code well enough
> >> to be certain that every vma should have a single protection and that it
> >> should not change afterwards.
> > 
> > No, I'm thinking this would naturally fit as a property hanging off a
> > 'struct dax_device', and then create a version of vmf_insert_mixed()
> > and vmf_insert_pfn_pmd() that bypass track_pfn_insert() to insert that
> > saved value.
> 
> Thanks for the detailed explanation. I’ll give it a try (the moment I find
> some free time). I still think that patch 2/3 is beneficial, but based on
> your feedback, patch 3/3 should be dropped.

It has been a while.  What should we do with

resource-fix-locking-in-find_next_iomem_res.patch
resource-avoid-unnecessary-lookups-in-find_next_iomem_res.patch

?

