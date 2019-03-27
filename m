Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6C6C3C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 20:35:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 23AE52054F
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 20:35:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="fwqIWCOy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 23AE52054F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B79116B0007; Wed, 27 Mar 2019 16:35:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B4E1D6B0008; Wed, 27 Mar 2019 16:35:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A650F6B000A; Wed, 27 Mar 2019 16:35:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7113D6B0007
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 16:35:33 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id e12so10711955pgh.2
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 13:35:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=QPOloOxRTaTdLOpUVbW+jky/YMc8w2U+BABUuwfTLpA=;
        b=K8sWKVkZ0H/ay45d0ffsgqwDb12IpMioRK2KqJuhaMIigizt6rs/q2PG3irlaO67Db
         vD9RG4S7rXyBj0xMXTfaIREAk76E0DLtX9/EpyHa7y/nSwoC6v6XioDgV6Yq9QlbVnQY
         oYYjC26TGhybOBB3LuxwfHQsiPb+U/B16WYv9IK9jtC/StgE5ZCcz35DhMZ8Ln1qdUnz
         EN0mXiJ+jT4lY4nHNHDwbGNnCGxYfMiUlUVcs9xFQfKwIATOhHjttgIV2rb2WEtDYNdZ
         4DfTgnPEqQ2G80xP89RVPdNqPVSe5QBAEnFh5sQmaUOQzyZtT6szoBkCM+Br6E+aUxRP
         uv9w==
X-Gm-Message-State: APjAAAUAlrUOc2Ou/VQQWz8vFSBQvR6hzjfrgsHxOLLr1xtqnJbe8Bso
	Km9epbfh8IKUDulIx/8WB3G2Wk1Gu6NGlxTZeUlu1eAbZzSz/CVOWVtVlKgK68r0EdvWiciFyvl
	CQVfy6R/mvOmXZY005QQ5hUayOCZZogvOpUiApFuy6wgt2IXbdb/gky6VthRMgH9m9Q==
X-Received: by 2002:a17:902:7289:: with SMTP id d9mr38570053pll.314.1553718933072;
        Wed, 27 Mar 2019 13:35:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz3cnLiWjrMiqcuGzLr9KoHLpYLHDK521XJMiqwhaARTBmraDfQ5yQy9K/UUvom4VO7/BP8
X-Received: by 2002:a17:902:7289:: with SMTP id d9mr38570019pll.314.1553718932375;
        Wed, 27 Mar 2019 13:35:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553718932; cv=none;
        d=google.com; s=arc-20160816;
        b=qnImmscWKvVrxo/OSz2Rzwr05D3637j1UcRz0ovZDlhAfCWoBtJJ+iE3gw4QRCVQ/0
         WX7SMd36Z3/JUeYaWUCznAaS8DKAQuQen+lj78EGeNmZO/WfZkqwTo8A/DKRfvWVWVWb
         JExsousjqqe9jLty+slGGZZKjINeulF/ZyH8VF7+YP1prSWJxapCRE88qRedhYEIQW2k
         CCd5I08r3rmKHsnNsl3cKoU/d/WTB3U3ginBrW8z19wa5bfrRtPR8KbVT4YM+XcWYx+A
         14p+X8lR6lGyqeciYv6UXRBej83SxecDvxMHhld3b6u02ejHoVbNjS3h3iAB1BS1NYvI
         mKDw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=QPOloOxRTaTdLOpUVbW+jky/YMc8w2U+BABUuwfTLpA=;
        b=zxnNYA0wMCRw2igG2l7ywgqphjKIyaEXlfgbMiwPQGYnps/TJ2qztfMe66oX9WlN7N
         hQi9SrMXaf7JNBEbdBKsT0Roq1/i0S7R1pTu7aTW/pKyFz/U2jxL+Ez9DgKijSfLjfUk
         WUQ/IColNTlK5FQKzN2H9O/tboln0ZhPqb/e4MCgVSRLQTd+QO1Cjv5G/XllZrZh3iSJ
         cJv4c0x7V+SQmSX6z/xsrSXLaCIGOwoSsQX1vrldhDmHqUW+jzgjDEp4Yltgq/Y/G8gV
         218PCCtQ9N+nCIhUVyTWfY3v/YxaKxa7ZvqjXV0k+vemHZQXqJSShWZ4kvTAbmp8WLef
         DLXg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=fwqIWCOy;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id i33si8295857pgb.99.2019.03.27.13.35.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 27 Mar 2019 13:35:32 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=fwqIWCOy;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=QPOloOxRTaTdLOpUVbW+jky/YMc8w2U+BABUuwfTLpA=; b=fwqIWCOyonfUBxY/jYxMe7Cta
	LrKDdKpoPiEiX7TXLGKbtSDRk/5QtQcNckocOCp8bTsUWepcPLwBuOqq+/xDvMEF0e+QopEX7cANr
	JoeMqtKfG8rbY1K3WEx87Da5m0eAaf9B8ttoJA2eDYrgHbS4IJ+Uz4vfee4bsIHsRezaMTFyIM5k4
	M7X+3il7hPr53Ks7kLecEjfE0hxw+RM8yd3estaG1wS7OUN7aDUIBasLdDqt3UultvUAFs1FvxzIj
	GZ23+02PfyUH5M0xsQGPoZWMQQr2saeEdpTLMAcGWdUMkQZnLaDb714B7QWoF3YcoW0lWU4jLbxFk
	Kx7LMerQA==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1h9FGa-0006KX-GT; Wed, 27 Mar 2019 20:35:20 +0000
Date: Wed, 27 Mar 2019 13:35:20 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Michal Hocko <mhocko@kernel.org>, Yang Shi <yang.shi@linux.alibaba.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	Rik van Riel <riel@surriel.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Keith Busch <keith.busch@intel.com>,
	Fengguang Wu <fengguang.wu@intel.com>, "Du, Fan" <fan.du@intel.com>,
	"Huang, Ying" <ying.huang@intel.com>, Linux MM <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Subject: Re: [RFC PATCH 0/10] Another Approach to Use PMEM as NUMA Node
Message-ID: <20190327203520.GU10344@bombadil.infradead.org>
References: <1553316275-21985-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190326135837.GP28406@dhcp22.suse.cz>
 <43a1a59d-dc4a-6159-2c78-e1faeb6e0e46@linux.alibaba.com>
 <20190326183731.GV28406@dhcp22.suse.cz>
 <f08fb981-d129-3357-e93a-a6b233aa9891@linux.alibaba.com>
 <20190327090100.GD11927@dhcp22.suse.cz>
 <CAPcyv4heiUbZvP7Ewoy-Hy=-mPrdjCjEuSw+0rwdOUHdjwetxg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4heiUbZvP7Ewoy-Hy=-mPrdjCjEuSw+0rwdOUHdjwetxg@mail.gmail.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 27, 2019 at 10:34:11AM -0700, Dan Williams wrote:
> On Wed, Mar 27, 2019 at 2:01 AM Michal Hocko <mhocko@kernel.org> wrote:
> > No, Linux NUMA implementation makes all numa nodes available by default
> > and provides an API to opt-in for more fine tuning. What you are
> > suggesting goes against that semantic and I am asking why. How is pmem
> > NUMA node any different from any any other distant node in principle?
> 
> Agree. It's just another NUMA node and shouldn't be special cased.
> Userspace policy can choose to avoid it, but typical node distance
> preference should otherwise let the kernel fall back to it as
> additional memory pressure relief for "near" memory.

I think this is sort of true, but sort of different.  These are
essentially CPU-less nodes; there is no CPU for which they are
fast memory.  Yes, they're further from some CPUs than from others.
I have never paid attention to how Linux treats CPU-less memory nodes,
but it would make sense to me if we don't default to allocating from
remote nodes.  And treating pmem nodes as being remote from all CPUs
makes a certain amount of sense to me.

eg on a four CPU-socket system, consider this as being

pmem1 --- node1 --- node2 --- pmem2
            |   \ /   |
            |    X    |
            |   / \   |
pmem3 --- node3 --- node4 --- pmem4

which I could actually see someone building with normal DRAM, and we
should probably handle the same way as pmem; for a process running on
node3, allocate preferentially from node3, then pmem3, then other nodes,
then other pmems.

