Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2685EC282E1
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 07:14:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B154C20674
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 07:14:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="H2HIjKph"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B154C20674
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1AA756B0003; Tue, 23 Apr 2019 03:14:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 15A516B0006; Tue, 23 Apr 2019 03:14:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 022676B0007; Tue, 23 Apr 2019 03:14:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id BBD6B6B0003
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 03:14:07 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id i35so778227plb.7
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 00:14:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=SDlbfGGT6h+AH6jrlBAq/GN8velgMypb49RBj12dJJc=;
        b=WNGyycIOooHrPUx9RjCVSu2Ph29gmTYXPWWEv6znyv/CLwxtbnPdGGEwDcVDPioX3b
         Qlmqlnjy/eZ7fYdqRF54Vfr2sRiXFf5LxqNLSexcpYjXNjc0K4l0Ckg6xC90lQmyFjrO
         t3gxHJtjmusyskqg23ILOGXctq/S7FiEUbarOEbF/N8fcYpiFd+DmCerVxcK4rScbe0N
         ZY5xalGAChP4xC0/XWM5Wa3ue/8H3QDNKc3+mRxR9TJoMW8HWSrPFtndnuEHtFIh/idy
         1jcp17cIm4vvMMddHePhx+c7c6iQYVCkIjh8BPFj5z3rYPlEdk7O0eMVxIBUXAEx/Czd
         4Hgw==
X-Gm-Message-State: APjAAAXHaONSCcMmZHARYXBBggu6voHhU6zNfV54HHmmVQOmxZ5OmtNS
	QuabBDgvPWTH+7769/Ok04BrNRkbsPOog6GnI9EGqiKqaZ+SvFAHGLQW5etTn3zqiy0EnCL8JQX
	DM6mBeQkEJtDmnBzitWukcMgWL9Xr0hD4xqW/JmFH8gqiXwQLbIOB7rg43oGS5B3S8A==
X-Received: by 2002:a63:3284:: with SMTP id y126mr23277663pgy.424.1556003647010;
        Tue, 23 Apr 2019 00:14:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyzBZF26FrqeZZdArrhIzLiRwHUGufnjouHhViv6P2IH31Xbr3u5aH8S56MKDqHydYo+Ex+
X-Received: by 2002:a63:3284:: with SMTP id y126mr23277577pgy.424.1556003646183;
        Tue, 23 Apr 2019 00:14:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556003646; cv=none;
        d=google.com; s=arc-20160816;
        b=ATTFQ0nxmPoF5JcssA1jm9qWQ/hTf+3PsTJNM/DG7akC7G7nWlN+jhPIHkfKKl6lP5
         2K+gReX6XH5L/NCAV4k6RQjeqF4zSjlOAgSTEEsOCDrz67mDBWuNpY/n9g9RXNyP0qBd
         TZsM/PVLCgLrAgEyNHtRCAvM5F8Q2wAe3svs/xro/vps8x399hCqxymIt6nNooUlOBXa
         31gYh4TNWu+L18KvEJ8AJ8d7Cg8rbszIa3e9XBIBPoeLERNfucKFLeZOuLLdjv8Cuu0m
         HO0VYUrBQCJ3yCWcko+EDR64fR2NRpY4YKNFynbylaGEowllTxp2iz99dX89iK/tU+ra
         ojSg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=SDlbfGGT6h+AH6jrlBAq/GN8velgMypb49RBj12dJJc=;
        b=MT5lOLGR3S7373gL8RMkQzKSbK+Jyg37xr5SEQsMZYREv7t6KXEpIIQRz1BhIcOX7a
         MTfteoMYLv1hGJ+aUg5/0VamKWPcoOGIgjdP18iY0iFo4bqAAWjjSd0E/9MwiXrO9SSX
         ck1pdJcjr/qThkLdzINUNKGlK39mdWUeIMW0lnfCefCcxadQ+Gufi3M9XPAgDA02SAw+
         XT0lmaGeKS2yPIU5BYah88gZuUxX/D0FLv5Ac9jIFLCO0dZpeYAIWQEzS+axblcOWffx
         0o08w4e93R+QKeRwOZsNTvevy51dk7Pzo0ou7xBiCqeR+U7xtWBUk8sQK9IBCj/S2mv7
         6jIg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=H2HIjKph;
       spf=pass (google.com: best guess record for domain of batv+307e856acde472aa9de6+5721+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+307e856acde472aa9de6+5721+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id c12si14231305pgj.461.2019.04.23.00.14.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 23 Apr 2019 00:14:06 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+307e856acde472aa9de6+5721+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=H2HIjKph;
       spf=pass (google.com: best guess record for domain of batv+307e856acde472aa9de6+5721+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+307e856acde472aa9de6+5721+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=SDlbfGGT6h+AH6jrlBAq/GN8velgMypb49RBj12dJJc=; b=H2HIjKphtjzOGFQrLmcu0oOFr
	5r3bAwWLkfQXSq9ayF7kYfnbhUjaU+tcCP3tyTatUyrT8kjp/mZymokWA2BvbP6qQr3yKHCAQRtUk
	/rdcDAeYXJDTVFa2DQ/xmqKnEtwTMu84elAhhsiAvLjU/eBU1t8FRYkPWntVgG8l+g30dwUwM/5/Z
	hlGqromgmM12sN2kE/0UwWS7366vJVO7iwyegEIytfYJEpPnGAAAwBc+VfAch2uGo4VcQ9qlP5wZU
	cFF1btw7ENuY8StXWiv/d74Z1+44bgUKCwY2vlR27IP+fhLq0QnZWB5h0llfduvDthG5CrdmkV0J7
	6BHcgY35Q==;
Received: from hch by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hIpco-0006EN-T8; Tue, 23 Apr 2019 07:13:54 +0000
Date: Tue, 23 Apr 2019 00:13:54 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Matthew Wilcox <willy@infradead.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Mikulas Patocka <mpatocka@redhat.com>,
	James Bottomley <James.Bottomley@hansenpartnership.com>,
	linux-parisc@vger.kernel.org, linux-mm@kvack.org,
	Vlastimil Babka <vbabka@suse.cz>,
	LKML <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org
Subject: Re: DISCONTIGMEM is deprecated
Message-ID: <20190423071354.GB12114@infradead.org>
References: <20190419094335.GJ18914@techsingularity.net>
 <20190419140521.GI7751@bombadil.infradead.org>
 <20190421063859.GA19926@rapoport-lnx>
 <20190421132606.GJ7751@bombadil.infradead.org>
 <20190421211604.GN18914@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190421211604.GN18914@techsingularity.net>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Apr 21, 2019 at 10:16:04PM +0100, Mel Gorman wrote:
> 32-bit NUMA systems should be non-existent in practice. The last NUMA
> system I'm aware of that was both NUMA and 32-bit only died somewhere
> between 2004 and 2007. If someone is running a 64-bit capable system in
> 32-bit mode with NUMA, they really are just punishing themselves for fun.

Can we mark it as BROKEN to see if someone shouts and then remove it
a year or two down the road?  Or just kill it off now..

