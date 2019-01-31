Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7AF19C169C4
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 12:34:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 453312087F
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 12:34:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 453312087F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sntech.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BBBF18E0002; Thu, 31 Jan 2019 07:34:38 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B6A388E0001; Thu, 31 Jan 2019 07:34:38 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A59548E0002; Thu, 31 Jan 2019 07:34:38 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 500CE8E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 07:34:38 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id w16so993965wrk.10
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 04:34:38 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=TFdjjFspTO7k4Rr4U9dNbgOJ/P8JG66BvAdwr8rFGGc=;
        b=mgtkzYGmEO/7CQ5S+eZE6cFQwM5Dz1ksPUy8Ms2chWMxwlSlpgz7XUBaJFWtAVAdxn
         wvKkqSe4PoRYUaiUg5+bGAHDpsgjJjW0wCdKNihyv5a0+BvVpzAyg6aW57562JCG681k
         Ty315hZmy6sH66YKbVGhzdFdveXnLKFYIy3UXO6EXjo1rM7t1SRxyG6vPCFk77zNVSO1
         4dPKYZcZNrP+c/eAOaK8ksrmpRnIxoatdGQw99cQJxHHxOoKmi6UdX0luVsTi2w8c55z
         SA2RDTUZXNAnebICGA6T/eQtYx3W3yGikvoI+cpL2KHW5k5mnZQLciFjxxa5f79kLmS9
         IAgw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of heiko@sntech.de designates 185.11.138.130 as permitted sender) smtp.mailfrom=heiko@sntech.de
X-Gm-Message-State: AJcUukeaD2AUdRMCh847g1l3QCV7cTXsefxG8p6Uf9v/rk/8wfhqrmAQ
	0MgbSdG6k9/dQzJGEx0plG/c6aoaOQsxXRT5aQ+HQCvvaZcwXnWVOpCniGU9Yn760TEAk2J95Rg
	bT8qkUA10e6rbf/dZ3vWwU7FdCazF2rnuE4dztKaz2xo7sH8oO3HADPrNQciL468O5A==
X-Received: by 2002:adf:91c3:: with SMTP id 61mr33112742wri.324.1548938077881;
        Thu, 31 Jan 2019 04:34:37 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7yMLMUaGlOMsdeAJEoPuEE4EsiV+llwu9e3TzfXKXrwPQ+JyfOucjCJJFCTR6aJOoCCWF7
X-Received: by 2002:adf:91c3:: with SMTP id 61mr33112704wri.324.1548938077052;
        Thu, 31 Jan 2019 04:34:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548938077; cv=none;
        d=google.com; s=arc-20160816;
        b=BeE+j2VFIbaAtCrQ2i/00GU5ZMneBeVx6NC2dOgy/n8BEdQHD5PMNJbtr4+Brh+WoQ
         PJIxEAqVfTlV0VUxLNvGLIuGRKGWxKCAs0jINlWjIysWXd8s7INDzHWLBSEkx+HAJJeG
         6Hflk9JwdpDqFItm5QO8XGZcypYiCbGepV3pQcyHq3DXHQvyABCh5/Uyxxy3PegGWZ+b
         GofyKxl65DjQhJLC5LTCVrhNTw00xGzKei9o6aR75JSCj8NTnryuBZW/Vc8+JBwrvJli
         z/+Bj1kgvjOyd7/U7vZxDQpc7AqAEKC7CufF5Pc1pIU4U3mea24/y+Ln0MjtqxBVYJa5
         I3Yg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=TFdjjFspTO7k4Rr4U9dNbgOJ/P8JG66BvAdwr8rFGGc=;
        b=uUeIRepL7YnUmr9UVH3Y1ljJDb5QHmTw6KuVp4UnfkqaRCxPdPT480bRsJV3Vv75AB
         gFw8dGIt6PjKkR+vU1EXMAvPgj4oLujJM1EE+6XdsssgyWvYupu93cGbarqrsz4mglfR
         Fvs//Spv0SWoY/1WKzbOhM92vDMDt8IQ03zGsRiAX0HgCToySxzvMUdiL+bp6YzMB4eY
         CzetXI5tOrzq8GLcCvXJYrAGyC7RHz0sjHIeCIbsroISfeKqDIfgDE0RkKBzfg9OF26b
         OOX5L08EQ52lxcDLP5vohnJixXcU5U9lwK+VoOpd04V6p8Zno6PUY/snldSiVKX8cMqf
         ayUg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of heiko@sntech.de designates 185.11.138.130 as permitted sender) smtp.mailfrom=heiko@sntech.de
Received: from gloria.sntech.de (gloria.sntech.de. [185.11.138.130])
        by mx.google.com with ESMTPS id v3si3452042wme.192.2019.01.31.04.34.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 31 Jan 2019 04:34:37 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of heiko@sntech.de designates 185.11.138.130 as permitted sender) client-ip=185.11.138.130;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of heiko@sntech.de designates 185.11.138.130 as permitted sender) smtp.mailfrom=heiko@sntech.de
Received: from wf0848.dip.tu-dresden.de ([141.76.183.80] helo=phil.localnet)
	by gloria.sntech.de with esmtpsa (TLS1.2:ECDHE_RSA_AES_256_GCM_SHA384:256)
	(Exim 4.89)
	(envelope-from <heiko@sntech.de>)
	id 1gpBXj-000441-H7; Thu, 31 Jan 2019 13:34:07 +0100
From: Heiko Stuebner <heiko@sntech.de>
To: Souptick Joarder <jrdr.linux@gmail.com>, hjc@rock-chips.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, vbabka@suse.cz, Rik van Riel <riel@surriel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, rppt@linux.vnet.ibm.com, Peter Zijlstra <peterz@infradead.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, robin.murphy@arm.com, airlied@linux.ie, oleksandr_andrushchenko@epam.com, joro@8bytes.org, pawel@osciak.com, Kyungmin Park <kyungmin.park@samsung.com>, mchehab@kernel.org, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, linux-kernel@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arm-kernel@lists.infradead.org, linux1394-devel@lists.sourceforge.net, dri-devel@lists.freedesktop.org, linux-rockchip@lists.infradead.org, xen-devel@lists.xen.org, iommu@lists.linux-foundation.org, linux-media@vger.kernel.org
Subject: Re: [PATCHv2 1/9] mm: Introduce new vm_insert_range and vm_insert_range_buggy API
Date: Thu, 31 Jan 2019 13:34:10 +0100
Message-ID: <1572595.mVW1PIlZyR@phil>
In-Reply-To: <CAFqt6zbxyMB3VCzbWo1rPdfKXLVTNx+RY0=guD5CRxD37gJzsA@mail.gmail.com>
References: <20190131030812.GA2174@jordon-HP-15-Notebook-PC> <1701923.z6LKAITQJA@phil> <CAFqt6zbxyMB3VCzbWo1rPdfKXLVTNx+RY0=guD5CRxD37gJzsA@mail.gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Am Donnerstag, 31. Januar 2019, 13:31:52 CET schrieb Souptick Joarder:
> On Thu, Jan 31, 2019 at 5:37 PM Heiko Stuebner <heiko@sntech.de> wrote:
> >
> > Am Donnerstag, 31. Januar 2019, 04:08:12 CET schrieb Souptick Joarder:
> > > Previouly drivers have their own way of mapping range of
> > > kernel pages/memory into user vma and this was done by
> > > invoking vm_insert_page() within a loop.
> > >
> > > As this pattern is common across different drivers, it can
> > > be generalized by creating new functions and use it across
> > > the drivers.
> > >
> > > vm_insert_range() is the API which could be used to mapped
> > > kernel memory/pages in drivers which has considered vm_pgoff
> > >
> > > vm_insert_range_buggy() is the API which could be used to map
> > > range of kernel memory/pages in drivers which has not considered
> > > vm_pgoff. vm_pgoff is passed default as 0 for those drivers.
> > >
> > > We _could_ then at a later "fix" these drivers which are using
> > > vm_insert_range_buggy() to behave according to the normal vm_pgoff
> > > offsetting simply by removing the _buggy suffix on the function
> > > name and if that causes regressions, it gives us an easy way to revert.
> > >
> > > Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
> > > Suggested-by: Russell King <linux@armlinux.org.uk>
> > > Suggested-by: Matthew Wilcox <willy@infradead.org>
> >
> > hmm, I'm missing a changelog here between v1 and v2.
> > Nevertheless I managed to test v1 on Rockchip hardware
> > and display is still working, including talking to Lima via prime.
> >
> > So if there aren't any big changes for v2, on Rockchip
> > Tested-by: Heiko Stuebner <heiko@sntech.de>
> 
> Change log is available in [0/9].
> Patch [1/9] & [4/9] have no changes between v1 -> v2.

I never seem to get your cover-letters, so didn't see that, sorry.

But great that there weren't changes then :-)

Heiko


