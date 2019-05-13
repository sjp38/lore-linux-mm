Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E2143C04AA7
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 11:21:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A29F1208CA
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 11:21:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="YYt/PTPn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A29F1208CA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2767B6B000C; Mon, 13 May 2019 07:21:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 226866B000E; Mon, 13 May 2019 07:21:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 116616B026A; Mon, 13 May 2019 07:21:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id C8D606B000C
	for <linux-mm@kvack.org>; Mon, 13 May 2019 07:21:09 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id g11so8188879plt.23
        for <linux-mm@kvack.org>; Mon, 13 May 2019 04:21:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=25lDMGlgbSYh90UdPyIPIRvlx65kRiSGWeTmnwcojy4=;
        b=FBTEaAviUNPOZMYO30tUwf2pVzMii9EGS326SBJOEq0mqI3gyURYBgEwTGHyst/qKm
         F2MSrq8XsInJ1Sp0WimK2z1tWydewTQuK6YXh8OJIlE7zIet07XpfXLASvMUtJO1o/U9
         6mr4x+nERqr1tUMmHkYFYwODOYJ2Eh/KhL4F2qwg0wNanb/gxTVGeaO5v5afjmstsm9k
         PJ1Q0tA7v+gX9sPbPFWV8493F9hIZjrgaaNzpm12HWj4BFtQKsBCeenoKtyaTjsRmHCQ
         iXpnqCEc98STjHuGdWJ22dZqm/4O57RyIsTcisSZPdBUYowQ5hTv7UIkAPJ/ne7goXu1
         jSgw==
X-Gm-Message-State: APjAAAWZnQ/7ZqhvuCf5yeRCH+pLRZ1Hbikryop4WMeXsw6O6XlGuzNV
	Pb9c0LSBxgxRkKijqId+lx+8KJrSYE9+yes1ITl3223hXbkIpEC4ZqihCglf6gN0Mklw79fxVoO
	eO28nFWkToO1Dxvr3bswH7mcYCOXGTX/ZaRog3SO7mPAEWaeiwxo7UKGurEhW/qvwdQ==
X-Received: by 2002:a17:902:728d:: with SMTP id d13mr11206619pll.1.1557746469047;
        Mon, 13 May 2019 04:21:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwbCOYgEeFYZqwv8ZBfaklUxzS/lLNR1SngsdM/q4fjVk4sy8hqBFiJeXMa3eBQRCxN9FF6
X-Received: by 2002:a17:902:728d:: with SMTP id d13mr11206543pll.1.1557746468352;
        Mon, 13 May 2019 04:21:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557746468; cv=none;
        d=google.com; s=arc-20160816;
        b=WM/p5HUBPvRpLljThZVSFwc9t2v+tdDYAQrS1ULR9wXk+bM0TuK146a9skoCi7aZPc
         5zOzxwbVlGdwIgOk5EH1zrl5zZEiSqSQB3jW9IRPSJVp1ie8Q5UbzP94yuqMHiO77p24
         SDuPtAmYMIZC9CvbV0SWxfWO7+tYAjP7eTOvbs5LyTWviGQMLteT1nlH7mWpbusuZKDl
         eG5osNDv//7/4ev5c72X7wyTmSnQWdtXckohcsclO296OhUGtHwB0g3/2K0pFPLRif1v
         wsLIG/Lfs14yX0uJSiZU+aoV7hDas8fXij0mZsxcaE+IRdkew5Zxgotdw+nvPNmpJiwO
         45HQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=25lDMGlgbSYh90UdPyIPIRvlx65kRiSGWeTmnwcojy4=;
        b=O5c/9JvMxY8japbwpHTsiiWrxxbGZqjCqOAm7JqnprP0GdZ+QzOOcmjIoxEAEqCLQ7
         +TFUNi5SvJKk8QUSOJB4Q+u9+nYv5suV+VZab1FHYjrqP0tGWfAfPPQR1tCnSHnK5NhO
         5yeK2UW1d2Qsx24OKJFXAij42SDhWdyWQk+vGke3vPWN8uHfOzIX/WGUY1tkXUFKMNQA
         qtfXD33OmGfYvKDKiY37MeoqZ41uBRps3wV0SqJLm6nNdob9qsuoSZrvSF0Ynq7crqBx
         AHD1eAuFG3+afdpncf9qT2tovRy3Bhf844irOb0o9hIFPR7L80kXVkZsB/U5fCViokTh
         wONg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="YYt/PTPn";
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id v10si16612774pgj.576.2019.05.13.04.21.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 13 May 2019 04:21:08 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="YYt/PTPn";
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=25lDMGlgbSYh90UdPyIPIRvlx65kRiSGWeTmnwcojy4=; b=YYt/PTPnGixYHZegYlk8jlOY3
	fZNQKHh/2aD4U9cepY4k6I9vlyxFuj85lEWbYtDS6ZsMmloqw3DsTD6k27jLEg2J6zzLqMbqVBvV+
	Tcpyd3ri5eQR6uVpf5yU9oDoZo1Ys5178GC7cWtni9h/scIVhRfAncUZojmVtx6mI5bB8Xr7iejUe
	7I5c4f9S2lLZZsd3J2wnN3LM5g+ltTTt6msL2YCW9lv9h5gemfmi2xtFbYUZS/77ylTBvcppr3KcO
	BacuoC1f7T2LWpgzsq23Cal1oukZydiJz7EgNKNymC3zlR5ejIg/RQ+wwn3DEETtHI1QofbUIS422
	OzBC+W03A==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hQ911-0005pR-ML; Mon, 13 May 2019 11:21:07 +0000
Date: Mon, 13 May 2019 04:21:07 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org
Subject: Re: [PATCH v2 00/15] Remove 'order' argument from many mm functions
Message-ID: <20190513112107.GB3721@bombadil.infradead.org>
References: <20190510135038.17129-1-willy@infradead.org>
 <20190513105138.GF24036@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190513105138.GF24036@dhcp22.suse.cz>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 13, 2019 at 12:51:38PM +0200, Michal Hocko wrote:
> On Fri 10-05-19 06:50:23, Matthew Wilcox wrote:
> > This is a little more serious attempt than v1, since nobody seems opposed
> > to the concept of using GFP flags to pass the order around.  I've split
> > it up a bit better, and I've reversed the arguments of __alloc_pages_node
> > to match the order of the arguments to other functions in the same family.
> > alloc_pages_node() needs the same treatment, but there's about 70 callers,
> > so I'm going to skip it for now.
> > 
> > This is against current -mm.  I'm seeing a text saving of 482 bytes from
> > a tinyconfig vmlinux (1003785 reduced to 1003303).  There are more
> > savings to be had by combining together order and the gfp flags, for
> > example in the scan_control data structure.
> 
> So what is the primary objective here? Reduce the code size? Reduce the
> registers pressure? Please tell us more why changing the core allocator
> API and make it more subtle is worth it.

The primary objective here is to avoid adding an 'order' parameter to
pagecache_get_page().  I don't think it makes the API more subtle; I see
it as fundamental to the allocation API as any of the other GFP flags.
It's a change, to be sure, but I think it's a worthwhile one.

