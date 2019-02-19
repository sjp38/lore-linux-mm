Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_NEOMUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7498EC10F00
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 14:59:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 310E021773
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 14:59:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="QvwpZODS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 310E021773
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A0BBE8E0003; Tue, 19 Feb 2019 09:59:31 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9BB0E8E0002; Tue, 19 Feb 2019 09:59:31 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8AAE28E0003; Tue, 19 Feb 2019 09:59:31 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 492768E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 09:59:31 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id t26so14410947pgu.18
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 06:59:31 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-disposition:user-agent;
        bh=bbQyydwGTTirw3UzuZQPM7i19iX5dNbackQGV5c/VjU=;
        b=BLOXZ7TFHAtOx9UKnc4Tg0HSvlrlVgC+OAbHtW5AXlt5TuPiUcILO1GSx+m09CCmLR
         JZLHk89Nl3eoHfd2Id3MnFd0n+lZSxXg//EnoM8OYhgHH9A3M1wjrE+sNaB45Uigy2Af
         sKkpO2xNg5o24luWx/BmEXyH3Bf/BNNQn4gzYEQ+7qgJeezYLKVuWSl6idIPRDxDTHDw
         jQO/QPwwRM/OeWFUvh5GjFsOBbqxYDsUozQxIXP9NJzWLi7n/kHmA4AmmDRWW7Covuar
         xafjatSoNiZADUoiwX+99rPAobfMWBqwh6jLi4ZykDJSLTYT/T99rU1eeUhuL6WEGEiR
         Ksug==
X-Gm-Message-State: AHQUAubMV9H4Ki95LaHgG5irxvccFy58y1Rvx5JhDAimA5KtasvajN4j
	RYoeJ5MgGMVi/bsrMIoQT7aGR4qd3an76wPUlb93W/RgXU6nyBQYH3EYc72PU43cL37i1NKPdHr
	/XsJOe8aZOYg5n6F8crLvJgmeUYdxS+weaKNyLooD31z+UPtMXAnKD82XONkIaTPaIlQzZYoPNa
	FdsCr3E4MEK2DoQ94kzGY+706XHndHnQD92JyTxrWwTwfae7fV1RIVbDBHn6sWO3S4jwl4yT88I
	f8qVhcovjUiiVnGKE0Lodq/aAi0AolepKrpLNMw57VgdS+8XEfGe3M+vO96la9+16KH2AJZ/0qP
	xqFSh6XHr1z0RYrpWj5Z7+fXhkTP2ellUn8ZOe9aod+rtpoe0bWQLv6Q0T75DUYx4kfPin75EtK
	m
X-Received: by 2002:a62:53c5:: with SMTP id h188mr18398002pfb.190.1550588370956;
        Tue, 19 Feb 2019 06:59:30 -0800 (PST)
X-Received: by 2002:a62:53c5:: with SMTP id h188mr18397946pfb.190.1550588370230;
        Tue, 19 Feb 2019 06:59:30 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550588370; cv=none;
        d=google.com; s=arc-20160816;
        b=P4QmPgRxlEnDcovwChL/6hSp6LCsw3gKfiSad2DFF5avj07ZTR1mWcfsN9MEIUhvI9
         rVtmLdp6EQWJbrvNyGO4Jf07sEINsfjxT7P3XPgs3nqLVMWnArH/VGlZa0pxFirTNlwC
         JMd7Yo/1sTyGO4hOzhgPodl5Ab2Gd3KQL3tH4Q9ArnNQSDXrKWyp6b+zM/XHluK/tgco
         kceHVF3hDifHL/lxL01achvcO7+dAekKgwUaz3M0/UfSjFzbNBVHXx9kB7pptuAcbD9f
         6bWxavWDAWVH5+2fwijllDAkChcOP6Q9LIMRgjoGJx6MuzBccwgAf+GssY6UN87v04FY
         1rHw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=bbQyydwGTTirw3UzuZQPM7i19iX5dNbackQGV5c/VjU=;
        b=AF8rN6gdUIYJrGOj23M6e7TKbxBgmtJMo0o0nggL7wvG4OrGQpPpf28qJDKmQyL/bL
         aSZXwGow54Sp+soDMD4/ZU7nzMZ29IhQGOrf4JF0QPylPbqIcLUzMb+C0sL8eWE/SqLi
         l9MeSd9zMgRPb08f+yS4f2gwLpBqDN+PPjQP8bNThCJL3CxkimS5Pu6gh30/2GVIvSRI
         oML4J53/FYvNYv2sdYaDH3vRMbOVS3vNLCvoUKmkJZZBFapbdOe4bJ8xLo+RC30/ZfCE
         q5jVIBim6ZDcF6jAJjGCHvbkNROnF7sfJQ4ti8U5GZwuvlSlGHmo6iwN82YuH+6rZxPs
         J2IQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=QvwpZODS;
       spf=neutral (google.com: 209.85.220.41 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id u23sor9788111pgk.1.2019.02.19.06.59.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Feb 2019 06:59:30 -0800 (PST)
Received-SPF: neutral (google.com: 209.85.220.41 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=QvwpZODS;
       spf=neutral (google.com: 209.85.220.41 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:mime-version:content-disposition
         :user-agent;
        bh=bbQyydwGTTirw3UzuZQPM7i19iX5dNbackQGV5c/VjU=;
        b=QvwpZODSOJ2StdYW8IfVo9SDX33D5VsDBx9qA5dRZydxW/loh8hW1FWcucykiNKNG1
         hX+1Y3+rE/N90tPoyq12ks0nhJaQOUl7Knw7vCV4QAm4H6hKzkMLbk66sotvbMgoc/Bj
         m0gGX+Q4cFmGVfIaMakXqUcfg1Pu88UUAPPGSELkrC7m9B5/OYoSaOMGb1TqDBrDjEkO
         23tHpTQ4Mu5lxElyJpPwXJUQv4HgyVEowqVWzNYfAv6f30uQrACorOuiFI36hmtAq6el
         ZkIMMPxgT8FgrNJGQ9GYv0P5YSmSam38aYe36tPmXi4rzjzuIPVE0Ey5d4VAUH5rNAcM
         Qdxw==
X-Google-Smtp-Source: AHgI3IZhBLBIl7gr45g4/ywjr+kx/11oegon7QkE1zbhG8r+ngTxBEesExphcdFsaEuh4bQjyvi9Sw==
X-Received: by 2002:a63:ed03:: with SMTP id d3mr24010990pgi.275.1550588369155;
        Tue, 19 Feb 2019 06:59:29 -0800 (PST)
Received: from kshutemo-mobl1.localdomain ([192.55.54.44])
        by smtp.gmail.com with ESMTPSA id p6sm23767707pfp.15.2019.02.19.06.59.28
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Feb 2019 06:59:28 -0800 (PST)
Received: by kshutemo-mobl1.localdomain (Postfix, from userid 1000)
	id DCC843002B2; Tue, 19 Feb 2019 17:59:24 +0300 (+03)
Date: Tue, 19 Feb 2019 17:59:24 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: lsf-pc@lists.linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: [LSF/MM ATTEND] MM track: Memory encryption, THP
Message-ID: <20190219145924.olggllneomorpenu@kshutemo-mobl1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

I would like to attend upcoming summit.

I was not very active in generic memory managment field last year. I hope
it will change this year.

I'm still interested in moving THP forward and I see there is a number of
THP-related topics proposed for the summit. I would like to participate in
the discussion (and hopefully contribute something).

The other topic I would like to discuss is memory encryption and userspace
APIs for it. See Dave's topic proposal[1].

[1] https://lore.kernel.org/linux-mm/788d7050-f6bb-b984-69d9-504056e6c5a6@intel.com

-- 
 Kirill A. Shutemov

