Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5420AC282CE
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 22:31:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DC5652067C
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 22:31:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DC5652067C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 61A6C6B0273; Tue,  4 Jun 2019 18:31:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5C9676B0276; Tue,  4 Jun 2019 18:31:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4923C6B0277; Tue,  4 Jun 2019 18:31:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id EF8516B0273
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 18:31:52 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id 145so3949377pfv.18
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 15:31:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mime-version:content-disposition:user-agent;
        bh=wj5mFFF+mZDCKAoRHmreS7YPus9uW+9PEgo6nV8B4BA=;
        b=OTLCx28FfJIC/A2AjPiH5W1RPv74GWFNpmcQKxRllabRCtAL7BtsFBKevjmNPRCtZi
         tXDVoCPvUg0BKqyOeHXPdn1puODZbvT1HWbtu2HYD67BC1lfCUKWSU8Oz49jRVgBprEM
         8rhPJlDfprwyGg4lL0p01FUGonvDgB+tbatYgmEKDhIBVsE6K2YCSgov+2Kd7qb3bBVt
         nmcKoiY86rT4FYJuqLVog569L//9TP5Wb1YZA0UgPVhI8+G/iwDjGrdTZAeMqcVB9595
         lSlWSbDpHIIzOzROqTYKA6Gq0q2DdfR6UonJJ++L3zpNFLp+g/aPODEA542z219FPSn5
         6LBA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of lkp@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=lkp@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUYOBL9NK4wEcdLz6AjId01OfMZHppmaD2ewVjapWc347l11ivJ
	HQa4HvktXbsGO5Ylk6lwuoeZluJp0Y3+18lVi3vlOKSpSLcZa42HkeIasltxHydgDCtj/YhBRfe
	7CtleRG0hwft6gx+hOWyHRm5CFGWYaPdMWdX7HB9sBMNvimx18eDZUIWBjxIXWkeHcg==
X-Received: by 2002:a62:e90b:: with SMTP id j11mr40382115pfh.88.1559687512315;
        Tue, 04 Jun 2019 15:31:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqya9PxQkJV+egIVSCObxZFN/9PguFE1FGhFWJhBeqLdVn3KlceE7Q2j9MZyBCzJOE8+n75T
X-Received: by 2002:a62:e90b:: with SMTP id j11mr40381998pfh.88.1559687510558;
        Tue, 04 Jun 2019 15:31:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559687510; cv=none;
        d=google.com; s=arc-20160816;
        b=uR9/o74RqWaaE27mLA7S4Yveui4NeWHuIUecVJo/hPjIECDj3Y/BQ10SU4N4AB+kWL
         ZeCQL3wGTeHPCIpL1LrOTk+iGznL6D/y7PXKFnXflevF0ucplVYYo6Ms/6sZygoR2Ouz
         G3lM/SZqQQz84xiDyGAG5u5F+7hwsmgkx+ELofHrf61VuW76C1DwhXLuVLXSu7jB1GX9
         truIpg/y4STsuSeKRSa1Yg5DF/MHGwYzASFd5LVVr6K2wA/9FH92E7eYMk+Dn3RoeSVx
         BrkucDlCNKMb1idp5bMPdTigVgavQap2oJKJra+SD3l3otu7gx5htpSyuYZjlIoyP7Yf
         w1+Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date;
        bh=wj5mFFF+mZDCKAoRHmreS7YPus9uW+9PEgo6nV8B4BA=;
        b=zHVJQnkp9AQ9YTJ+Jk8Zrnon1mWKGdwR72bDRnR5eOEw7Oa1pB6V7Fh1IAeHh0RoMu
         KpG10NJ7wLEEDsC7iSU3axT/KQ7rmQiqGM7xX1tutQHrXjH/FSjXyU4N9EaeCEHjVmtx
         nQNB7OEq7JI/b8xrxD2hFFLJbzADz6rzXZuyCOHaCktIpWUj4DptB3WbE4qWgMsvB0ez
         5EBf7ajku/tPDoqcUBKtzoVLoV19EDCYkScl9u1CmWPTjafoe5NLcL7Etma6s9lSP2Gs
         Y3MO2mPeKL0N3Oy+85SsLnVFhJLg3K7BiXg5Y22/2EAhfPYHkfpjLRANHKpt/k5tfFbA
         YAOg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id h4si23004586plr.24.2019.06.04.15.31.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Jun 2019 15:31:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of lkp@intel.com designates 134.134.136.24 as permitted sender) client-ip=134.134.136.24;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by orsmga102.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 04 Jun 2019 15:31:50 -0700
X-ExtLoop1: 1
Received: from lkp-server01.sh.intel.com (HELO lkp-server01) ([10.239.97.150])
  by orsmga008.jf.intel.com with ESMTP; 04 Jun 2019 15:31:47 -0700
Received: from kbuild by lkp-server01 with local (Exim 4.89)
	(envelope-from <lkp@intel.com>)
	id 1hYHy6-0005Nd-Qi; Wed, 05 Jun 2019 06:31:46 +0800
Date: Wed, 5 Jun 2019 06:31:35 +0800
From: kbuild test robot <lkp@intel.com>
To: Maninder Singh <maninder1.s@samsung.com>
Cc: kbuild-all@01.org, Roman Gushchin <guro@fb.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Vaneet Narang <v.narang@samsung.com>, Joe Perches <joe@perches.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Memory Management List <linux-mm@kvack.org>
Subject: [rgushchin:kmem_reparent.6 16/236] fs/btrfs/zstd.c:396:28: error:
 incompatible type for argument 1 of 'ZSTD_initCStream'
Message-ID: <201906050632.nJ0WheQd%lkp@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="LQksG6bCIzRHxTLp"
Content-Disposition: inline
X-Patchwork-Hint: ignore
User-Agent: Mutt/1.5.23 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--LQksG6bCIzRHxTLp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

tree:   https://github.com/rgushchin/linux.git kmem_reparent.6
head:   8e4d7c939f45c5d285469aee9e02777da23b582f
commit: 96d3001e2f61722b7e3d26456133ff2779de268b [16/236] zstd: pass pointer rathen than structure to functions
config: x86_64-lkp (attached as .config)
compiler: gcc-7 (Debian 7.3.0-1) 7.3.0
reproduce:
        git checkout 96d3001e2f61722b7e3d26456133ff2779de268b
        # save the attached .config to linux build tree
        make ARCH=x86_64 

If you fix the issue, kindly add following tag
Reported-by: kbuild test robot <lkp@intel.com>

All errors (new ones prefixed by >>):

   fs/btrfs/zstd.c: In function 'zstd_compress_pages':
>> fs/btrfs/zstd.c:396:28: error: incompatible type for argument 1 of 'ZSTD_initCStream'
     stream = ZSTD_initCStream(params, len, workspace->mem,
                               ^~~~~~
   In file included from fs/btrfs/zstd.c:19:0:
   include/linux/zstd.h:555:15: note: expected 'const ZSTD_parameters * {aka const struct <anonymous> *}' but argument is of type 'ZSTD_parameters {aka struct <anonymous>}'
    ZSTD_CStream *ZSTD_initCStream(const ZSTD_parameters *params,
                  ^~~~~~~~~~~~~~~~

vim +/ZSTD_initCStream +396 fs/btrfs/zstd.c

5c1aab1d Nick Terrell 2017-08-09  368  
5c1aab1d Nick Terrell 2017-08-09  369  static int zstd_compress_pages(struct list_head *ws,
5c1aab1d Nick Terrell 2017-08-09  370  		struct address_space *mapping,
5c1aab1d Nick Terrell 2017-08-09  371  		u64 start,
5c1aab1d Nick Terrell 2017-08-09  372  		struct page **pages,
5c1aab1d Nick Terrell 2017-08-09  373  		unsigned long *out_pages,
5c1aab1d Nick Terrell 2017-08-09  374  		unsigned long *total_in,
5c1aab1d Nick Terrell 2017-08-09  375  		unsigned long *total_out)
5c1aab1d Nick Terrell 2017-08-09  376  {
5c1aab1d Nick Terrell 2017-08-09  377  	struct workspace *workspace = list_entry(ws, struct workspace, list);
5c1aab1d Nick Terrell 2017-08-09  378  	ZSTD_CStream *stream;
5c1aab1d Nick Terrell 2017-08-09  379  	int ret = 0;
5c1aab1d Nick Terrell 2017-08-09  380  	int nr_pages = 0;
5c1aab1d Nick Terrell 2017-08-09  381  	struct page *in_page = NULL;  /* The current page to read */
5c1aab1d Nick Terrell 2017-08-09  382  	struct page *out_page = NULL; /* The current page to write to */
5c1aab1d Nick Terrell 2017-08-09  383  	unsigned long tot_in = 0;
5c1aab1d Nick Terrell 2017-08-09  384  	unsigned long tot_out = 0;
5c1aab1d Nick Terrell 2017-08-09  385  	unsigned long len = *total_out;
5c1aab1d Nick Terrell 2017-08-09  386  	const unsigned long nr_dest_pages = *out_pages;
5c1aab1d Nick Terrell 2017-08-09  387  	unsigned long max_out = nr_dest_pages * PAGE_SIZE;
e0dc87af Dennis Zhou  2019-02-04  388  	ZSTD_parameters params = zstd_get_btrfs_parameters(workspace->req_level,
e0dc87af Dennis Zhou  2019-02-04  389  							   len);
5c1aab1d Nick Terrell 2017-08-09  390  
5c1aab1d Nick Terrell 2017-08-09  391  	*out_pages = 0;
5c1aab1d Nick Terrell 2017-08-09  392  	*total_out = 0;
5c1aab1d Nick Terrell 2017-08-09  393  	*total_in = 0;
5c1aab1d Nick Terrell 2017-08-09  394  
5c1aab1d Nick Terrell 2017-08-09  395  	/* Initialize the stream */
5c1aab1d Nick Terrell 2017-08-09 @396  	stream = ZSTD_initCStream(params, len, workspace->mem,
5c1aab1d Nick Terrell 2017-08-09  397  			workspace->size);
5c1aab1d Nick Terrell 2017-08-09  398  	if (!stream) {
5c1aab1d Nick Terrell 2017-08-09  399  		pr_warn("BTRFS: ZSTD_initCStream failed\n");
5c1aab1d Nick Terrell 2017-08-09  400  		ret = -EIO;
5c1aab1d Nick Terrell 2017-08-09  401  		goto out;
5c1aab1d Nick Terrell 2017-08-09  402  	}
5c1aab1d Nick Terrell 2017-08-09  403  
5c1aab1d Nick Terrell 2017-08-09  404  	/* map in the first page of input data */
5c1aab1d Nick Terrell 2017-08-09  405  	in_page = find_get_page(mapping, start >> PAGE_SHIFT);
431e9822 David Sterba 2017-11-15  406  	workspace->in_buf.src = kmap(in_page);
431e9822 David Sterba 2017-11-15  407  	workspace->in_buf.pos = 0;
431e9822 David Sterba 2017-11-15  408  	workspace->in_buf.size = min_t(size_t, len, PAGE_SIZE);
5c1aab1d Nick Terrell 2017-08-09  409  
5c1aab1d Nick Terrell 2017-08-09  410  
5c1aab1d Nick Terrell 2017-08-09  411  	/* Allocate and map in the output buffer */
5c1aab1d Nick Terrell 2017-08-09  412  	out_page = alloc_page(GFP_NOFS | __GFP_HIGHMEM);
5c1aab1d Nick Terrell 2017-08-09  413  	if (out_page == NULL) {
5c1aab1d Nick Terrell 2017-08-09  414  		ret = -ENOMEM;
5c1aab1d Nick Terrell 2017-08-09  415  		goto out;
5c1aab1d Nick Terrell 2017-08-09  416  	}
5c1aab1d Nick Terrell 2017-08-09  417  	pages[nr_pages++] = out_page;
431e9822 David Sterba 2017-11-15  418  	workspace->out_buf.dst = kmap(out_page);
431e9822 David Sterba 2017-11-15  419  	workspace->out_buf.pos = 0;
431e9822 David Sterba 2017-11-15  420  	workspace->out_buf.size = min_t(size_t, max_out, PAGE_SIZE);
5c1aab1d Nick Terrell 2017-08-09  421  
5c1aab1d Nick Terrell 2017-08-09  422  	while (1) {
5c1aab1d Nick Terrell 2017-08-09  423  		size_t ret2;
5c1aab1d Nick Terrell 2017-08-09  424  
431e9822 David Sterba 2017-11-15  425  		ret2 = ZSTD_compressStream(stream, &workspace->out_buf,
431e9822 David Sterba 2017-11-15  426  				&workspace->in_buf);
5c1aab1d Nick Terrell 2017-08-09  427  		if (ZSTD_isError(ret2)) {
5c1aab1d Nick Terrell 2017-08-09  428  			pr_debug("BTRFS: ZSTD_compressStream returned %d\n",
5c1aab1d Nick Terrell 2017-08-09  429  					ZSTD_getErrorCode(ret2));
5c1aab1d Nick Terrell 2017-08-09  430  			ret = -EIO;
5c1aab1d Nick Terrell 2017-08-09  431  			goto out;
5c1aab1d Nick Terrell 2017-08-09  432  		}
5c1aab1d Nick Terrell 2017-08-09  433  
5c1aab1d Nick Terrell 2017-08-09  434  		/* Check to see if we are making it bigger */
431e9822 David Sterba 2017-11-15  435  		if (tot_in + workspace->in_buf.pos > 8192 &&
431e9822 David Sterba 2017-11-15  436  				tot_in + workspace->in_buf.pos <
431e9822 David Sterba 2017-11-15  437  				tot_out + workspace->out_buf.pos) {
5c1aab1d Nick Terrell 2017-08-09  438  			ret = -E2BIG;
5c1aab1d Nick Terrell 2017-08-09  439  			goto out;
5c1aab1d Nick Terrell 2017-08-09  440  		}
5c1aab1d Nick Terrell 2017-08-09  441  
5c1aab1d Nick Terrell 2017-08-09  442  		/* We've reached the end of our output range */
431e9822 David Sterba 2017-11-15  443  		if (workspace->out_buf.pos >= max_out) {
431e9822 David Sterba 2017-11-15  444  			tot_out += workspace->out_buf.pos;
5c1aab1d Nick Terrell 2017-08-09  445  			ret = -E2BIG;
5c1aab1d Nick Terrell 2017-08-09  446  			goto out;
5c1aab1d Nick Terrell 2017-08-09  447  		}
5c1aab1d Nick Terrell 2017-08-09  448  
5c1aab1d Nick Terrell 2017-08-09  449  		/* Check if we need more output space */
431e9822 David Sterba 2017-11-15  450  		if (workspace->out_buf.pos == workspace->out_buf.size) {
5c1aab1d Nick Terrell 2017-08-09  451  			tot_out += PAGE_SIZE;
5c1aab1d Nick Terrell 2017-08-09  452  			max_out -= PAGE_SIZE;
5c1aab1d Nick Terrell 2017-08-09  453  			kunmap(out_page);
5c1aab1d Nick Terrell 2017-08-09  454  			if (nr_pages == nr_dest_pages) {
5c1aab1d Nick Terrell 2017-08-09  455  				out_page = NULL;
5c1aab1d Nick Terrell 2017-08-09  456  				ret = -E2BIG;
5c1aab1d Nick Terrell 2017-08-09  457  				goto out;
5c1aab1d Nick Terrell 2017-08-09  458  			}
5c1aab1d Nick Terrell 2017-08-09  459  			out_page = alloc_page(GFP_NOFS | __GFP_HIGHMEM);
5c1aab1d Nick Terrell 2017-08-09  460  			if (out_page == NULL) {
5c1aab1d Nick Terrell 2017-08-09  461  				ret = -ENOMEM;
5c1aab1d Nick Terrell 2017-08-09  462  				goto out;
5c1aab1d Nick Terrell 2017-08-09  463  			}
5c1aab1d Nick Terrell 2017-08-09  464  			pages[nr_pages++] = out_page;
431e9822 David Sterba 2017-11-15  465  			workspace->out_buf.dst = kmap(out_page);
431e9822 David Sterba 2017-11-15  466  			workspace->out_buf.pos = 0;
431e9822 David Sterba 2017-11-15  467  			workspace->out_buf.size = min_t(size_t, max_out,
431e9822 David Sterba 2017-11-15  468  							PAGE_SIZE);
5c1aab1d Nick Terrell 2017-08-09  469  		}
5c1aab1d Nick Terrell 2017-08-09  470  
5c1aab1d Nick Terrell 2017-08-09  471  		/* We've reached the end of the input */
431e9822 David Sterba 2017-11-15  472  		if (workspace->in_buf.pos >= len) {
431e9822 David Sterba 2017-11-15  473  			tot_in += workspace->in_buf.pos;
5c1aab1d Nick Terrell 2017-08-09  474  			break;
5c1aab1d Nick Terrell 2017-08-09  475  		}
5c1aab1d Nick Terrell 2017-08-09  476  
5c1aab1d Nick Terrell 2017-08-09  477  		/* Check if we need more input */
431e9822 David Sterba 2017-11-15  478  		if (workspace->in_buf.pos == workspace->in_buf.size) {
5c1aab1d Nick Terrell 2017-08-09  479  			tot_in += PAGE_SIZE;
5c1aab1d Nick Terrell 2017-08-09  480  			kunmap(in_page);
5c1aab1d Nick Terrell 2017-08-09  481  			put_page(in_page);
5c1aab1d Nick Terrell 2017-08-09  482  
5c1aab1d Nick Terrell 2017-08-09  483  			start += PAGE_SIZE;
5c1aab1d Nick Terrell 2017-08-09  484  			len -= PAGE_SIZE;
5c1aab1d Nick Terrell 2017-08-09  485  			in_page = find_get_page(mapping, start >> PAGE_SHIFT);
431e9822 David Sterba 2017-11-15  486  			workspace->in_buf.src = kmap(in_page);
431e9822 David Sterba 2017-11-15  487  			workspace->in_buf.pos = 0;
431e9822 David Sterba 2017-11-15  488  			workspace->in_buf.size = min_t(size_t, len, PAGE_SIZE);
5c1aab1d Nick Terrell 2017-08-09  489  		}
5c1aab1d Nick Terrell 2017-08-09  490  	}
5c1aab1d Nick Terrell 2017-08-09  491  	while (1) {
5c1aab1d Nick Terrell 2017-08-09  492  		size_t ret2;
5c1aab1d Nick Terrell 2017-08-09  493  
431e9822 David Sterba 2017-11-15  494  		ret2 = ZSTD_endStream(stream, &workspace->out_buf);
5c1aab1d Nick Terrell 2017-08-09  495  		if (ZSTD_isError(ret2)) {
5c1aab1d Nick Terrell 2017-08-09  496  			pr_debug("BTRFS: ZSTD_endStream returned %d\n",
5c1aab1d Nick Terrell 2017-08-09  497  					ZSTD_getErrorCode(ret2));
5c1aab1d Nick Terrell 2017-08-09  498  			ret = -EIO;
5c1aab1d Nick Terrell 2017-08-09  499  			goto out;
5c1aab1d Nick Terrell 2017-08-09  500  		}
5c1aab1d Nick Terrell 2017-08-09  501  		if (ret2 == 0) {
431e9822 David Sterba 2017-11-15  502  			tot_out += workspace->out_buf.pos;
5c1aab1d Nick Terrell 2017-08-09  503  			break;
5c1aab1d Nick Terrell 2017-08-09  504  		}
431e9822 David Sterba 2017-11-15  505  		if (workspace->out_buf.pos >= max_out) {
431e9822 David Sterba 2017-11-15  506  			tot_out += workspace->out_buf.pos;
5c1aab1d Nick Terrell 2017-08-09  507  			ret = -E2BIG;
5c1aab1d Nick Terrell 2017-08-09  508  			goto out;
5c1aab1d Nick Terrell 2017-08-09  509  		}
5c1aab1d Nick Terrell 2017-08-09  510  
5c1aab1d Nick Terrell 2017-08-09  511  		tot_out += PAGE_SIZE;
5c1aab1d Nick Terrell 2017-08-09  512  		max_out -= PAGE_SIZE;
5c1aab1d Nick Terrell 2017-08-09  513  		kunmap(out_page);
5c1aab1d Nick Terrell 2017-08-09  514  		if (nr_pages == nr_dest_pages) {
5c1aab1d Nick Terrell 2017-08-09  515  			out_page = NULL;
5c1aab1d Nick Terrell 2017-08-09  516  			ret = -E2BIG;
5c1aab1d Nick Terrell 2017-08-09  517  			goto out;
5c1aab1d Nick Terrell 2017-08-09  518  		}
5c1aab1d Nick Terrell 2017-08-09  519  		out_page = alloc_page(GFP_NOFS | __GFP_HIGHMEM);
5c1aab1d Nick Terrell 2017-08-09  520  		if (out_page == NULL) {
5c1aab1d Nick Terrell 2017-08-09  521  			ret = -ENOMEM;
5c1aab1d Nick Terrell 2017-08-09  522  			goto out;
5c1aab1d Nick Terrell 2017-08-09  523  		}
5c1aab1d Nick Terrell 2017-08-09  524  		pages[nr_pages++] = out_page;
431e9822 David Sterba 2017-11-15  525  		workspace->out_buf.dst = kmap(out_page);
431e9822 David Sterba 2017-11-15  526  		workspace->out_buf.pos = 0;
431e9822 David Sterba 2017-11-15  527  		workspace->out_buf.size = min_t(size_t, max_out, PAGE_SIZE);
5c1aab1d Nick Terrell 2017-08-09  528  	}
5c1aab1d Nick Terrell 2017-08-09  529  
5c1aab1d Nick Terrell 2017-08-09  530  	if (tot_out >= tot_in) {
5c1aab1d Nick Terrell 2017-08-09  531  		ret = -E2BIG;
5c1aab1d Nick Terrell 2017-08-09  532  		goto out;
5c1aab1d Nick Terrell 2017-08-09  533  	}
5c1aab1d Nick Terrell 2017-08-09  534  
5c1aab1d Nick Terrell 2017-08-09  535  	ret = 0;
5c1aab1d Nick Terrell 2017-08-09  536  	*total_in = tot_in;
5c1aab1d Nick Terrell 2017-08-09  537  	*total_out = tot_out;
5c1aab1d Nick Terrell 2017-08-09  538  out:
5c1aab1d Nick Terrell 2017-08-09  539  	*out_pages = nr_pages;
5c1aab1d Nick Terrell 2017-08-09  540  	/* Cleanup */
5c1aab1d Nick Terrell 2017-08-09  541  	if (in_page) {
5c1aab1d Nick Terrell 2017-08-09  542  		kunmap(in_page);
5c1aab1d Nick Terrell 2017-08-09  543  		put_page(in_page);
5c1aab1d Nick Terrell 2017-08-09  544  	}
5c1aab1d Nick Terrell 2017-08-09  545  	if (out_page)
5c1aab1d Nick Terrell 2017-08-09  546  		kunmap(out_page);
5c1aab1d Nick Terrell 2017-08-09  547  	return ret;
5c1aab1d Nick Terrell 2017-08-09  548  }
5c1aab1d Nick Terrell 2017-08-09  549  

:::::: The code at line 396 was first introduced by commit
:::::: 5c1aab1dd5445ed8bdcdbb575abc1b0d7ee5b2e7 btrfs: Add zstd support

:::::: TO: Nick Terrell <terrelln@fb.com>
:::::: CC: Chris Mason <clm@fb.com>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--LQksG6bCIzRHxTLp
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

H4sICEnv9lwAAy5jb25maWcAlDzbctw2su/5iinnJaktJ7o4imu39IAhQQ4yJEED4EjjF5Yi
jx3VypKPLrv2359uACQbIChnt1JrTXfj3nc0+OMPP67Y89P956unm+ur29tvq0+Hu8PD1dPh
w+rjze3hX6tcrhppVjwX5hcgrm7unr/++vXtWX/2ZvXbLye/HL1+uD5dbQ8Pd4fbVXZ/9/Hm
0zO0v7m/++HHH+C/HwH4+Qt09fDP1afr69e/r37KD3/eXN2tfv/lFFof/+z+ANJMNoUo+yzr
he7LLDv/NoDgR7/jSgvZnP9+dHp0NNJWrClH1BHpYsN0z3Tdl9LIqSOPuGCq6Wu2X/O+a0Qj
jGCVeM/zgDAXmq0r/jeIhXrXX0i1nSDrTlS5ETXv+aWxvWipzIQ3G8VZ3oumkPB/vWEaG9vt
Ku0B3K4eD0/PX6ZdwYF73ux6psq+ErUw56cnuLt+vrJuBQxjuDarm8fV3f0T9jC0rmTGqmGb
Xr1KgXvW0Z2yK+g1qwyh37Ad77dcNbzqy/eincgpZg2YkzSqel+zNOby/VILuYR4MyHCOY27
QidEdyUmwGm9hL98/3Jr+TL6TeJEcl6wrjL9RmrTsJqfv/rp7v7u8PO41/qCkf3Ve70TbTYD
4L+ZqSZ4K7W47Ot3He94GjprkimpdV/zWqp9z4xh2WZCdppXYk03lXWgCxIrsofDVLZxFDgK
q6qBrUFGVo/Pfz5+e3w6fJ7YuuQNVyKzItQquSZzpii9kRdpDC8KnhmBQxcFiKnezula3uSi
sXKa7qQWpWIGZSOQ6VzWTCRh/UZwhWvdzzustUiP5BGzboOZMKPgpGDjQDSNVGkqxTVXOzvj
vpY5D6dYSJXx3OsYWDdhmpYpzf3sxgOlPed83ZWFDvn5cPdhdf8xOsJJBctsq2UHY4KqNNkm
l2REyw+UJGeGvYBGNUc4k2B2oHWhMe8rpk2f7bMqwStW5e4m1ovQtj++443RLyL7tZIsz2Cg
l8lq4ASW/9El6Wqp+67FKQ8yYG4+Hx4eU2JgRLbtZcOBz0lXjew371G115YzxwMDYAtjyFxk
CTl0rURu92ds46BFV1VLTYiaFeUGecxup9K2G88DsyVMI7SK87o10FnDE2MM6J2susYwtaez
88gXmmUSWg0bmbXdr+bq8d+rJ5jO6gqm9vh09fS4urq+vn++e7q5+xRtLTToWWb7cAIxjrwT
ykRoPMKkQkcBsRw20SZmvNY5qrKMg1IFQnKeMabfnRKXAFSXNoxyJoJAIiu2jzqyiMsETMiF
ZbZaJGX6b+zkKIywSULLalCU9iRU1q10gp/h1HrA0SnAT/CGgHFTx6wdMW0egXB7+gCEHcKO
VdUkIgTTcNCBmpfZuhJWPsc1h3MeNefW/UF06XbkQZnRlYjtBjQrSIbFJN0tdKAKMFuiMOcn
RxSO21izS4I/PpmYXTRmC15XwaM+jk8DM9s12ruV2QaWaXVSpFV117bgc+q+6WrWrxl4yllg
DCzVBWsMII3tpmtq1vamWvdF1enNUocwx+OTt0RNxQNMSifAjD4Pb3DueWLjslLJriUi0LKS
O9nnxBaCr5KV0c/IYZpgw3Axbgv/ENmstn50ugBrDgluccr9hRKGrxk9Bo+xRzRBCyZUH2Im
L74A08Oa/ELkZpNUQaCsSNvl6bQi17OZqJx63x5YgKy9p5vr4Zuu5MAKBN6CL0jVEzI/DuQx
sx5yvhNZYIQ8AuhRd70we66KWXfrtkj0ZU8opVBkth1pAp8DvW1whEALEy8X5YT8Rs+a/ob1
qQCAy6a/G26C33A62baVICpoSMGRC/bBSS0GXDOummj2Grgh52AAwRNMnrVC0xCyMOy59aEU
DU/xN6uhN+dKkYBO5VEcB4AofANIGLUBgAZrFi+j32+Ck8p62YLdhKAZfVN7ulLVoBRSfkJM
reGPIOwJYhenDUV+fBbTgK3JeGtdZFh9xqM2babbLcwFzBlOhuxiS1jP2SvCB+FINWgzgbxB
BgepwSiknzmh7kAnMD1pnK/HJLak2IBOqGbh3OidBdYj/t03taBhPdGbvCpAtyra8eKuMIgb
0Hskiqwz/DL6CXJBum9lsH5RNqwqCGPaBVCAdaspQG8CJc0EYTTwdToVWrR8JzQfNpLsDHSy
ZkoJelBbJNnXeg7pg2OboGtwfmCRyL+gwRIUdpNQKDEeDThqzg3INdYa0uVaO4sJqmnC0LLJ
olOCGC4I4JyVQmiCeaAnnufUAjn+h+H7MRSa/MTs+ChIV1gvz6f32sPDx/uHz1d314cV/8/h
DvxEBi5Vhp4iRAWT+7fQuZunRcLy+11tw9ykX/o3RxwG3NVuuMFVIKeqq27tRg5kDqHeR7By
KdMuP+bVGHhIaptW0hVbp4wP9B6OJtNkDCehwMXxrlHYCLBondF/7RWoAFkvTmIi3DCVQwia
p0k3XVGA22jdqjHJsLAC66q2TGHCM1BjhtfWpmLiVRQii1In4BcUogok02pgaw6DaDLMdQ7E
Z2/WNAlwaZPNwW9q27RRXWbVfM4zmVMRl51pO9NbY2POXx1uP569ef317dnrszevApGD3ffO
/6urh+u/ML/967XNZT/6XHf/4fDRQWjydAvmefCLyQ4ZcAPtiue4uu4ica/R51YN2F3hMgrn
J29fImCXmPhNEgzMOnS00E9ABt0dnw10YyZIsz7wFQdEYD4IcNR6vT3kQADd4BDDervbF3k2
7wS0o1grzO/koVcz6kTkRhzmMoVj4FH1wHM88hdGCuBImFbflsCdJtKF4Lw6p9MlAhSn3iKG
kQPK6lLoSmEGatM12wU6K15JMjcfseaqcek7MOVarKt4yrrTmLVcQtuwDT30vq0hygWZT1LY
zWXV3Jd/L2Gn4IRPiaNns7a28VLg5/U3LM6qjlhEe123S007m9wlXFGAA8OZqvYZ5jCpkW9L
F9pWoNHBiP9GHEM8SM3wkFHE8CR55pKk1ky1D/fXh8fH+4fV07cvLpvx8XD19PxwILZpWDqR
VzptXErBmekUd5ECVcmIvDxhbTLvhsi6tRlW2qaUVV4IvUn67wZcJGDacHjH6OATqipE8EsD
PIF8Nvlnwdx2sJSk3kdkaiIBAQpuBYojbTomiqrVepGE1dP0fASYzqVJXfT1Wixs5Mg4/loC
ouaqSwVRsgamLSC8GVVP6mpiD5IJviGEE2XHabYWjothCjDwgTxsHlvOSXQrGpukTm9ImEgc
/EXwVoZpTD3u0geDxE7u4qx8PJXvZyZH0iFfNHbyB2zvRqJTZieWHKjevk3DW52lEei1pu/d
wB6HzkxsDah/PXCeasC8e1XvsmJnlKQ6XsYZHWmrrG4vs00Z+RWYtN+FELCjou5qK5QFq0W1
Pz97Qwns4UD8VmsVnKfL82IAyyueTnZAl8DnTqqCPIsFgyTNgZt9SV2tAZyB78s64vpsWu44
IoZxiFnRyipDdiSnIWIJHh+Ip/NUJkeYVYDYO8TCmV5G6mcwjdYoanRhwWCteYk+ThoJ6u38
t+MZcvCOp533GErs9IGuqSdmQXU2h2BwLMOTtpfhPSr3iPVkAqi4khgLYoZireSWN/1aSoNX
BDpioIzPAJjbrXjJsv0MNXJDoFURAfywZHUAi7d9egMqPtXjH8CA558DgdhwcIor8OADA0rC
rc/3dzdP9w/BXQqJ67wt6JoogTCjUKytXsJneOkRKHZKY82JvAi1+hg/LMyXLvT4bBZMcN2C
9xGL/nBr6CUkvAx+u522rxYZyHZw6zqCYlmeEIE0T2A4MKfbCjbjE63OY79ARMf7m3WSQlgu
FBxqX67RUZu5L1nL0HsyECqKTCcYiuYgQB4ztW8DQ4UnQlApee+od4X0IcR7iyxrRYRBBa/x
lrrpJXKoA5zHNwo81EBh41D5Oy/UOmVu0izha4/oKQoP8FaBD54I3rdXEYVHRQUMFmWT5FsU
kt6A/0Z4qkINUA1eC95vd/z86OuHw9WHI/I/umstTtIpjim7nsaH4m7T0RDxSY2pJNW1IX8j
CaovdBDqYTUToWseK0AsQcBrqguilmuj6DUN/EJ/XRgR3DCEcH8o4+YfLZDhMWF6zSr/gfg4
WD6Ljw48Gg0BBaopFl7DWLRLqoQL0zWLwgGv6WqRhIMjkQSPLIExCm7ilu+JaeCFCH6AUIY5
I4TV4jKZ+Nc8wyCekm/e98dHRynf931/8ttRRHoakka9pLs5h25CM7pReLlOEqH8kgcXpRaA
oXcy0a+Y3vR5R6Mv1+CPANZu9lqgaQa1BY760dfjUDAUt2ksL9jTTZk9W7xFwLRsyhse+mWV
KJt5v/ke4j8s23EnWbE9WHziTYG4VF0ZuqqTEBF0sPnOl6fY1Na4DM0u18RH8XIf2algzTFJ
XIoxeXN1bpMlMN/UhQPoOFHAknMzT1zbjEkldrzFW+Ng9AGYttUvBOcz28PyvB/MF8V5VeGP
xO/i92gU/EXz8RjmuBy+Myc2rBCxbvDd6LaCABOzLK1J3LJ7Kkyw2KRPopKM0plNG5A4r+v+
v4eHFXgxV58Onw93T3Zv0Dqu7r9gIS1JXszSR64Qgfi3Lm80A5Br3imA9ii9Fa29ZkiJvR8L
466qwvttciRkIkRcaxDU3OWNTVhuiqiK8zYkRkiYgwEo3o0OtJNjWPcXbMtn8faIDroYcv6k
03yHl475/DoAkFg5O2xJsnM/01nb3E7LFb6lI/Ta5b8x5kr3nFVBNH7xzvm8WNwoMoH3Gt7e
JfvHmLn0jsmSQzfmU5CvCG/Ofg06xOpTDeZdbrs4qwccvDG+3hObtDShayH+ksCtwjr4muTC
J18Sae2Glsm8jeurzVRvIr/NzrSlnr2jjVnGzQ98sELP4whKo/iuBy2hlMg5zbqGPYFxSlRI
UgoWb8WaGXDv9jG0MyYs6rPgHYwul7ou2LyBYSlmdfsaaisE2SSG4sBeWkeoKV8xBmRptMhn
B5G1bda7KuFkmwgu2lpM7qkFJY1pNDArS3D+bFFs2NjHshE0ikJGy+J2DZVx14IizuPFxLgE
sy7teJshB8qYKeFvw8Daqllvw7KdrVrqdqAS0uchwk70epEZo/IiN5tOG4lOvtnIdKbXMWip
0trGS0veoSLFy8YLdMtlUy3OH/7C7MMUw8FvdGE7Jcz+hSSrW0LNlovNrcC1nKiwEB7WPiTI
J8pyw2ORsHA4U854zMIWNUtNzyi4aP5IwvFmKGFITPGykoIAspJlxOgsvwzyRS06rbIFWREL
l9oDV8LfSUXmQskxfTg5DEWQrh9KcVfFw+H/ng93199Wj9dXt0HGaNA4YcrS6qBS7vC1ASZI
zQI6rusckaiiguzkgBhKDLH1Qp3Rdxrh/mvgooWE7awBFnLYcrLvzkc2OYfZpIUu2QJwvtB/
9z8swQZnnREpZyDYXrJBCwcw7sYCni4+hR+WvHi+0/qS27e4nJH3Psa8t/rwcPOfoBplCsrb
yLRZRs/sdYNl0iBnMljMlzHw7zrqEPeskRf99i3VesPlmONf3mjwjnegAJcuwFrOc3CiXG5f
iUbGnbVv3D1OHapxuzOPf109HD6Q+IEWfCfkddxO8eH2EEpvaO8HiD2ZCsK0oHKUImvedPGZ
jkjDoydTZHZ2CmOWzJ7b+JhhiCW/GzHZBa2fHwfA6idQ5KvD0/UvP5N0Nthrly0lYQLA6tr9
IBkrC8ELoOOjIOZF8qxZnxzBwt51YqFMCOsp1l1K1fpKC7xhiFKmQTLIcsReF+vkri2s0+3B
zd3Vw7cV//x8exUFk4KdngTZ7vCe+/QkpT9cZoLWDThQ/NvejHSY5sXsCjADvZbxb9fGltNK
ZrMNDPtwPVjakMSur7h5+PxfYPZVHos9zwPnB372sihS5ZVC1daJAYMeJP/yWoigDwC4crHU
gz7EZQyfimYbzK00EJ5jEq/wgTPtSOgMH4OtC9gnsWARios+K8r5eKSyQJYVH6c/UwIw+Oon
/vXpcPd48+ftYdoqgcVzH6+uDz+v9POXL/cPT07+/UbBnHdMpdaIKK5pPRNCFF4417B9LAi9
3Nq3w7YudDc0vlCsbYfHRgSfsVZ3WA0iMdGRjn+BLH73Ovk6bYv1bkpiIa/g6Z3EZLZxTx+3
EN0aUVqRSArb/7KrY8bJrqSlunIEhfVsdod9WczA4ubw6eFq9XEYx9k3qtMXCAb0TEQCmdru
SNpkgOA9JnDx7IGvwxRxMamH93gnGtT9jdhZZS8C65rewSKE2WpXWoE99lDr2M1H6FgU5m7R
sOI77HFXxGMMSgQ0v9njTax9iu0T9SFprNqCxa73LaNhNFZWdPg0PEqIBRtsG8c3vHbldVoL
uH3qFl/d7vABMT4/mFwUC6LegqNxz3zxKSwoKZflmamMoSATqyBvng7XmJ59/eHwBTgJzews
H+ly+OEVsMvhh7AhhHW38+PEpCsVTfnadqsH/NTRAMHILq5v2I41ZlNdS1e34Kask4kx2Zq4
Ks13AX5rX0SvBmYVbHaGU4aua6ylw3cdGWYsotwDJp3xTT3IR78OnyptsQ4s6tw+OAF4pxow
JEYUQe26HVrADmNJZ6KgcZuca2ocv81p+Au7YfFF17irLa4UZoZsnUHA+5YsCMKnV+K2x42U
2wiJ7hD8BiXcyS7xTlfDkVpH0j1wTuR4wPUweH/hn7vMCVDbu+h9Aenv0ANvgMzcfb3BVR73
FxthuH9jSPvCCkw93iLZ55muRdQlBOq6Z5iHt+bHcU/oEDo6TcPo8ADwoxCLDV12mUI2F/0a
luAeKEU4e+dI0NpOMCL6G+xJqzjmHICJIwxe7AsuV8UZvfqaOkmMP7whUH7TwlvE6aQm+X8Z
m3i14fY863xCEO9PZszimNu91/QVZfE4Xid4XsE7ovh0XDtXfrSAy2W3UAPsnW30pt3b/uEj
HwlarDWZ6FMb4u+VfbE0cdgX4KQlHkMFPBMhZ4W6g+HwxbwB2t5XklEX2kaNYGvlzOdwqxYG
PHHPIrZGNOYj1DP80lhdtJ17LguPw2NFPH8WHsuU3NlK7QU12NjSBl/RnWCRRbq+7ZJ92srw
3YL20rIwzvmZzTIfCmJ4hu86SPwr8w6vg9CK4asxFJfELvBLYdBa2E92GDa7LcUjt82Hu/nU
/IL3DrG5xQGSej9sNT2hSPRL3j8sdUJJEl15tCXH6oI5W7X7wUqYKsY6fvTfs5ibS9hb4a6e
x3ckxP/Bj/KI0t9Tks8H+Cl5PIvssH1SY5l01uL0ZI6aVopMFB9lCjZZTwM22gzfvlEXl1Ru
F1Fxc8dvyeYp1Nhc4UMe96EIEtw52NLHL6bFtrD1pydDQQlsYMqJA78h8Lum8gd8cUxeoem5
d53J3es/rx4PH1b/du/bvjzcf7zxGfMprgcyv0sv1edZssEdHp6UDg+rXhhp6AgdcvySDcQG
WXb+6tM//hF+5wk/uuVoqBMWAP2qstWX2+dPNz7ROKPEj7VYbqtQfPfpXMZEjUUtDX4kAPR6
+11qVCXOuCaj9WBy8bOz70Q5w5rBBtT4uJWKuX3qqfEBI6lXc0qS8oRnVvtFHpvCSBfbIE3X
IH6xsUOnC69l7q1+Orvh+9EqGz/1FQrCjFKkL+Q8Go9S8YU3ICCkNUwWJCXvt/gqdnHF2n3m
I64wWIdVNvio3SbLFH8XPt0YnruvdZkEBhfS09t4w0u8d5yj8GFQPgeDGpfGVNGXLeZYrIRM
7oj9eoSvt7I+WjqLhWQX63QSa/oABUR9Vj6y1L2Bm5R7KxIvxEHHRQZd41nJls0vWNqrh6cb
FIaV+faFPqIaq3vGmprz4J5ZQlww0qTzcuIyTTEYOl2QGiKSGgfjFiCmHg1T4sU+a5al+qx1
LnUKgd/ryYXeRgEEPgm57HW3TjTB7+MooX056gzdQUubaqbdThYkr1+cvy5FeuldZb8a9mLb
rklNaMtUzVIITEQmx8Lk/dnb75wu4fcU1XCNE7FXoAJmyTfk1Pod3rjMYOin0zQfgm01mPv0
nFzp678OH55vg/sBaCekK2TNwVH7f8q+rEluG1n3r3TMwwlPxPF1sVbWgx5AkFUFNTcRrKX1
wmhLPXaHJbWj1T4z/vcXCXABwExS4whZKuQHEDsSiVxcOzyLeP8Quc/gHSE6fECb5X6vXzK9
eyxzXXac3Hhe0WQeDL9EbuxaS3XanbWxmeterqVrZtPQp2hoXu28hspsE93cnmZZXYCgo8os
T3363DRVV3tFcc3t22N1lUlGEfXXCFrPi2l/hvFghDdAaIqfubriWUfpA4/aeWRoouQAf4Eg
wnXDZ2GNJm77vDEgBn1M81bzn6dPf709woMC+F2902Ytb9ZsjUR+yGq4PY04eIykfnDP6Yyu
MQhKBj9M6irWerLCThNTrOSVsIXqbXImbJM6KLuVwQwPJUSTdHuzp68vr3/fZcMT7ki2PGl2
MdhsZCw/M4wyJGnbbO2rBd6COpsS5+rbaesn0n2pHCxHbqBHnGCki3ngGhmXjBDjj5qdTisg
Z573KqiP7W7Nzglq5lCu9h+bu6ZIhGq0m97WzeE2XUA3Rwq9CWCHKalf3apM12YXByu9tZcp
Avtx56Q1CWZGe3dXLA1Rs+ZaZNx4lumg5A/a5FVT+34lInVJs6/Wxoi2gId660PZGRFw3ktr
dnU9peeA8QgZV++2m83Ks0IiTZrdzhmln65loWZCPjLkI0RHFi+OiIxYemUP2HpH0ZnxqePt
bEa0Dcrs7ksGkuIVqiWg2hbH2ZrShBkLHfwlvFJjC+ViCglay9NiPNiERmFPRV/wgapqyuS7
nbMsLIkZWurH0rOiGCjRGb+yfZRj3zfd3bZ95tCvwN0jj91ENd+SqnJlytrHF6ZeEnfOXsYS
zv6MMh4RPHMyNLHPcsrUxivg1YcgTuW0l85F1w5WTlE6N+fhC2gHmvLBiveirkOTkHOUCqyj
BwMx7e/0okb/kLIjduKXre2WbaKqTa/BXycuoQCHdeqadsqYqxM0KrpOjLyVOQIc+nwcDrWx
zo1KU7u1YonV7dy1npH3kXEfIVuxlj6F86e3f7+8/gFac6PjV+259/YnzG+1DJilgAr3Gfd2
o/iFzEtpswzbUooqnR5sf2PwS21Vx8JLap2tDZpKkNgb0OJOGACibmsN+Nrg+BLWGHOoTBWC
2s0Oes0JCDeJD8SldkmY1KgWmDOYojTMiut/WKX29iva9ty9k8DjTATSl2Q8K71ygQky5h1O
6cag3SBYfUJol6SKCvswUJQyL/3fTXzi40RtGjdKrVjlbG7Qh6IUuBcTQzwCG5tk5xtmA6wR
TX3Oc5tbhJabJvgaxT3F68zM7o2+v/BOLUUmFY8XuI0ziZaenLo2qM8X98KzaNZVvtSYJxSg
neNxeyD9UJxHCUPbnU/A9GoY7l9E0xKJd7gwlYPdhZi1Q9XcTLDmMR6Dl8CoHW2xkU+KXBuH
Pp2fI4E7Gukh10TW14Iwa+hRJ/WvGYSchzxEKR4zoIdckiMjhKQdJL9M0+HyCDNvGpXO1PWS
5HiEgh7xkBDTo0eIVJ0sig2dRsV8tuN4jPNmw/hHmP1Dx2V7s6NLrrwmeuSu8Hf/+PX50z/c
j2bxxhN496v4snW3hcu23XrhpnjAlwyAjANTOCmamBDawyrZTi3K7eSq3CLL0q1DJsotsWi3
yAapcqg9aDjZdYoU9agDVFqzrbCHDE3OYyG5vpPWD2XifQH9rLORdSk4dHx8eXU7R/CmgE9S
U4IeP6ryMjlum/SK7Gk9VTF0GDM5ABz/saqzITAMKFAAI+hu2GVdQgAbKcXhwTsRdCZ1d9Xv
suo8z0rPo5MNNloZ+MNBOSYOZ1TMea9HDf++41zE30dRfOxzEWANwJakKZyNWnnH6kCYzV4f
qs6osOeKyUoOTWgdh54eP/3hPat2BSPXQ7t4rwCrWpLXDq8Cv5s4OjZF9J7nqFd7jWj3IHP2
6wkEe864JAQnTyxAB5bMQURf0Pi5GvzQl6sYFR44GkXwS11CFBMA7IuXrq8DzrsN7tY0Xdb4
9hZVIj6SOqOa+5DMZ7FUEqY9m7K8CRfLwPGnO6Q2x0uFV8LCZBQmTrj6NN64lOOe0VjNUtyI
5Lbc4EWxMkIJ5amgPr9Ni2vJiCgXSZJAwzZrasMZO58fmswxR7dxDqoZsoBYU3ZHR2rsmX5D
RAsryiS/yKsYuZToxgC5Udn11HdhnxMdJDtlSt/jcsJP4kniG63uFV3TOLkgPQD0dAXxiYB7
UBh/fuZcYjeAyg6GUB103BDH4ZMrNWkfifXpUgmc6bMw5vTBznKgVhCkQj40rhvv6INzMoJz
6/eo7Em7vVbHMcvaZ2/vuqKmYBvIzJVG3L09fX/z9m7doPuaCsyiF3hVKF6uyEXti4za3X1U
vEewpSDWgLOsYrHAmEvO8oFfAsufil3dhIhnbsIRAKZhavXFT//3/AmxXALkxZQ+jBqk3Tix
ZoEqU49q0WDCORVR9woO6m3Ap7qaDZraTH2I890Odx8EVKGNdvIDYeYKBlKTpZcJu9dW1xMl
yPfMd1Pk0ouD7wKz7/SzVDtUZ6rjaCxBzhBEkhpCFJ1kcpouY6Djm7ueAtP57y8M1JqnIBmP
2CRAd+EU4DwagM7+ctxBbk6jSGJEq3iUMGRiW7sFYaR1UJtNVeK3e0W855izUGJzATlYdXak
W1dRJaljk3EFrV/XRkUntaF+uhYfjnASBo73glQnaYszeJTEO7nNCD2VpGB7psNIqjmJHzk9
noOVWudSvSly1Gi0R4NOlGqaDq0AYsHkGEfj2uvX7k7rEiCeKzKrsoaf9M6UgUy+nPTVr2I2
dnrek6+OBzzFZna966UYXU4+hqpEeGKDkU9xav8a9yOod//4+vzt+9vr05fm97d/jIDq6nVC
8rf94DyeWllk99xCXdncgrShNPa+2qHU9Q/646SjRmnv5ouhrKtQqTiffrgXeLA3dVjuS/cw
3peDDo1zqu7R+1K/IQhcCMKT8gR3N/ywPuDrvJQMVERpye8B4/mt27qX4t7EY7CAa98d2yTF
B6maOoFCNBsHz9aZrVSo2YvkAuyktc0wkRaXkTVE0jJE/b2aOOMNWLgXFfhN3WscvSf/RxtT
UjqJCaxC5zW7e9yHHABw4cxlztuk9tUZHzIFaRJeoW6tILsss1GRsvPNNZEJi4fR01AXHQQM
NqMfAk/GJNLtLLPEr04TE2eWyUBcbDUxuuLfce1c2wQ0bCjQtMsBL4AL7aQIaJXx3d85pHOD
/moHRuCH8qtboObkz9jNDqhOzEJIAMUPOG5bHzMuUdgetnXhldfgkknX7F4nLss4wxaH/qBn
4TVMc3zut27PBibfozUiwofOBnLwtDAHkid3hhi1WpXx08u3t9eXL1+eXi2HJYYbffz8BA6N
FerJgkHQzcFWv2O25rDWZTkbuwmJn74///btCrbhUCf+ov6BeAQwU/2q/fprewFqWsPxR+h6
Tn6qVwjFO6bvtOTb5z9fFG/qVQ6MmrWtIvplJ2Nf1Pd/P799+h0fBqdseW0v9nWChyqaLm2Y
ppzZQdlKnnHB/N/aRqDhwubOVDazibd1//nT4+vnu19fnz//ZqtkP4AL+CGb/tkUSz+lErw4
+Ym18FOSPAERfDJCFvIkIufQKuPtbrnHRUnhcrHH3IiY3gBhpX5Td550KlYK78I92KY/f2qP
0rvCV1g4G9ubU5J6jhas5Ea/bP/jl++/Pn/75feXNzAN6fk+dcTXWekydl1ak4FJD3oJYXnM
UsdwsazMN3vHIjqY+jvfY8mXF7V6X4cGHK6tl4uhJNA6ZH05livNHmusYP1Go2TXE4nvHKKt
TVcCnBJXraDj6Hb23aKvgZW4EA8P/T2xIl5jDEA73TTFNEaNEH8bBJjxDdGCtWU6MhxWAAl9
thExxYF8OacQHScSqaiFfVtUdyRHGdP8bsTSiZjATNidGIK0HlzOCYiHJOfmGpCguwYxm3u/
RZ813+i4brKT+92hUKyuax6rPY6Pg68dc8JiJ6txQUuB+crx/X8au2Pfr2ebhC18W11E64q0
d6BeYamL5PP28unli62PlJeut9LWBMcRRrZWOfk5TeEH/nzQggj5UkeGQ0/KWHWPKFfLG37J
6sDnLMEkFB05LYpyVHGdqhVGjcliOC5We9gvADf59biKMBlu3xtRbDN0XbK8n+4AeQsnCq2Y
Jdq0EtvGDDHFbJq+vQbbVbi27opxVWQg3OXxhfBHCQcZLPqkxqIomYsrfMd5w+lTtfnYZEu9
7hvTpTv8Rlp9yRKLWequiirVyJWQHtdZkAs55EH0rnT6gUVqw5KOBEqno6HfgVKz6mi7g7ES
zUT0i2ppxLXchoyUOzoJut0XRr//+fsnZw/rxjLeLDc3dW8qcCZSHTTZA1x3cH4iAhdBxK3q
xPKaipB4hHsHxx+0anHI9JDhn+Ryv1rK9QJ/DVW7fFpICBYGjgzHQtHuSqCOjxR/jmFlLPfh
YsmI1ygh0+V+sVhNEJe4JBycDBaVbGoF2mymMdEpoIT6HURXdL/AN8JTxrerDS71jmWwDXHS
WUYtd90cJNuvQ6IKavMg7xwd80/7ACsvJcsFPr350j+pjD1Ooo7RzLlydSOuKWpTWuLTqaWP
HSz5iIzdtuEOf9NtIfsVv22nACKum3B/KhOJD0sLS5JgsVijS9drqNUx0S5YjNZF65DsP4/f
7wRITv/6qoOytv4m314fv32Hcu6+PH97uvusNoHnP+Gfrrey/zr3eDKmQq6AI8OXFKi86DA3
Ja6X34XowI+FntpkxJ7QA+objrgYvv+S8bHHXPAT9+UuU/Pxf+5en748vqmmD/PMgwDPFw8O
39wK6NibYzcDkosDkRFIaJ6LYjHwLIqC5hjqeHr5/jZk9IgcLqsuUdePxL/82QeKkG+qc2wd
+J94IbN/WsLUvu7xyCneVDdbXHGSXz/gY5jwE75jg+mbmmMcXBYRIiANqWp5+wEE9VB3YhHL
WcMEum6dA9YRFAvXbbmIxwtYc0QmszX1+jkiBZjbWRcgJmLtqtk2KOC2nFLncYNqQkqrg+Gl
6gvKoef1dWXaWpjYID+ppf/H/969Pf759L93PP5ZbVCW19aeP3VkhPxUmVT8COjIhSQAfamY
rlxf+BH9JMfYUt1UrgUcee11nOLDjkfHGEenaveh+prr9E3d7YvfvUGS4P17PCyKk0OTjdNR
jCLBMT6RnopI/eXqivVZMIFsT9ZeB2VWjvNWpfkcOrP9Nnsdd+1CnllMEFAoxWND1cH5aFeq
ZrBux2hl8NOg9Rwoym/LCUyULCeI7URcXZub+k8vPvpLp1LiWuiaqsrY34iraweQDHvRNVPF
FVmaNMahRn6q4Dv1oSG1TQBHAFKHRW4NwtY+wLhe1TGfm0y+CzZWBKYOY2QEo9htDjVj8t5+
GB3K1/K4ugbrXk9E7Ldg77dgP9eC/Q+0YD/Zgv1kC/b/XQv2a90CuwhImnjCNZv9RRKGCi35
nE1M9risFSeGH5WmYmDrIR8mvsAqnhGKdZqeqPotsY05U1y2Pp3y5Oo4ZusJtrnhkMhEGhU3
hOJH5ewJZg90uqWsV5D61U9dwuanH+uPybtgcEVm55qiL02p3p6ZsaouP0yMw/kgTxyNFmc2
ilrYQiizT52lOolc8bs5QVImT8iTilPThwpnXDoqPuAta1xeyB1QnTiELML0BHWVa5mQ2yrY
B2Q/HGNbxNKdi2LU36KcmK9gbUtoV3Z0FhD6aaYNdTKxK8uHbLPioVq4+K25rSC2IDTpgx7U
Rk2thdfUDylT3MFouCF55khLy6kxiflqv/nPxAKHBu13+I1ZI67xLthjJn2mfB0rxR+jMuPT
p2OZhQtCcGPm/4HhgjRNHWvEGA7glKRSFCpjgV8cHEalfdib6Do8XB7GovfnhuMspmadYabx
w+uS/KduCYkfyyJGVwgQy6w3CuHWi/K/n99+V/hvP8vD4e7b45u6bw1qghZjqj96sl/edVJW
ROCnLtWKGWCHO/hN67MMce2/ehVWC4oH2yWxZkw74UERSqExUqSu0MbqJ9WqnulWDfzkt/zT
X9/fXr7eaR0Eq9WDjClWTLenoeB+/YMcaSY7lbtRVYsyc7MylQOmG62hhlmhAmEohbiNBj/D
le01jbBHNPNCXcOEJKZ8271TRGI/1cQL7jpNE8/pxJBeqKVliHUi5fj6W8724TCsem4RNTBE
wnG7IVY18XZjyLUaoEl6GW53+KzXAMWcbtdT9AfaU58GJAeGz0lNVUzDaosLIHv6VPWAflvi
ut4DABdta7qow2UwR5+owHsdaXuiAoqrUps0Pm81IE9qPg0Q+Xu2wg9qA5Dhbh3gcl4NKNIY
FuoEQPFu1NaiAWrzWS6WUyMB25P6Dg0AIweKRzeAmFB10wuYsNAxRAgUXYFJ40TxavPYEtL/
cmr/0MRWK2UCUIlDSrBc5dQ+oolXkUdFPlafKkXx88u3L3/7e8loA9HLdEHKAs1MnJ4DZhZN
dBBMkonxp7kQQ29P3onx/+ibXDhaOf96/PLl18dPf9z9cvfl6bfHT3+j+lQdR4KL7RWxVdCg
qzF+V+luaojvzsz1pxprlRDjbx4toQFfV8yOVB5r+ctilBKMU8ag9WbrpCFvvBAQDBRdbX+k
I/dIJmXiFt8C2qdISSqA9goDWReLYtxnsaOxG9O6urqQg8sgd/DWhWPGcnZMKq0Q6mnDW4Uo
XrqswMGVrV4DIhe15rUr4NY7ov2VM2j3ixKNjq7IWnHCKU7mrJQn12OzStYO4hVncxHgGIes
o6c53qWoW/kHr0DtLZF2ZaUQSYVJTWPLoZKNhgA1fZQ9qkj/FjRQPiZV4dTbnoN2EX26ugxS
nxkwEls/evBT9uBPiDMhco+zkdsqZ4i1DhP+nUPK7hP/Q+qQodxLwwQY2ZG6nawHzpG7xNng
LpgqVfvTRYmtyoT/gNpSD2c3SoP5DRL9UdqBj2G2MKpN6wRK64VH4LUjLW9T2xeI0X4O1r93
wWq/vvvp8Pz6dFV//ok9gx9ElYBZFdr2jtjkhfS6rnudm/qMtWWDFQ2c7q3eHyaqVhxaa49m
bavC6sc86U29hh1TneeUfY7WQUEpyQcd4InQecwnlGhAeSYhlBhUI8GaHKWJkiRdbhQFDlFC
k/JYY558VA1kwp0eU/+SRZpYakR9WhfTxsG7RsLaXlelaK+MlfqHrZxanx3LVvWzuegx0gGq
CAugy6Tyl/GfNXR3mqFOkOErFx1kZmA6Kt9Gv7UUFQdLIcFT0Y+fv7+9Pv/6F7wpS6P6zSxf
8g7r0+m//2CWrqoJRLV23IJl8dg8S+2QcVE1K15g6ocWgsWsrBM3eLRJAjWJ6iDQXcouQJ3j
zgpK6mAVUD64ukwp4/o8dE4bmQpeSGIpD1nrxHH8zZPcD34NKU2R6fAVR/CPibOVRhuklnMt
zNhH19V1krN+HOby2vFIsjgMggCy2vr9Cq7DZg78rFH5zzNOLWQIBHo7oorO9sfVrpTXwmGR
2AfCD7idr3KXcJ8OTS5sP4h1unR+Be6vxP3pjlKKX2rs750V24PxRBYmqgoWq1nu7OFrXJ4c
8Qx2QNQnQX5zhoB7bwndlgTTyQquYn43p2vmThAojpBJPijWNfNVy+yMMzNKNZh7AeijfKaT
IEPuBqJWOztmtuVkuoiz06/16ZyD6QCsrhI38LQhl3lIdMR7ycZUR2wzMbUDV0l2DVPx4ezb
iIyIXsWQlhtBvqvSYWT7Nf5o0JNxkVRPxuflQJ6tmZC8cHcidJ7aWSDmXe76wr016iZC8Nez
W1rsMQTqnE6FZwSyDBZrbNRGUJ3QZFd8h26pGTGghqzub5iDlDhZ3zZDRVtRTROuret4nO2D
hbWDqfI2y+0N2Ytvopo9SmNXpSlOl47iuVRTmjAjtQqBsMuJU4MoWc6OSfLRDcpqkQ7n96KW
Z6RNh+zyPghnTuqTM1yn0nu9RDKc2TVxjSjF7CQV4XJj61jYpDYoajfhVQXcX/7PxP+ttmdb
z0ocI+fHePdWiehCFDcnKxzA3k+kLEgmdkKxXhB6pIpA5SEu+4csWBAxxo/41eM9bnMw9Hwr
AndOjUuGu7yR966Hcfg9pV0CZDiLPeltT35YuqU90G7l7Bqr6rK8cJZPlt7WDeEeSNE2tIa/
osrrJPmA2Wrb9RG88iL6yjDcBCovLku5lx/DcD1SDsVLLto1PxxwLN+tVzMLWueUSSbQ1ZY9
VM7ahd/B4kjMuYSl+czncla3Hxs4PJOEc38yXIXLmS1G/TOp/OgzS+KQuNxQl3BucVWRF64V
f37A7sN2LrdNQvHjSSvXzEyYsrlNO1ztF8i2zG5UzuV9a7nuZyn9qypS3YtifSztAB08LHZu
Iha6uHc+o2CoS3orR+sFPMmPIncdcJ6YDnyPZH9IwJb0IHJHmNCV+GGkgfQhZStKa/FD6rPs
FomYv+pjtyRvyHyoENmu4RmUvTOHR/7AwazC8wXaU6tsdqCq2DV63i7WM8sBPDfUicV5hMFq
bzvaht91UYwSmtJlcrtksO9u6isI2XGBVgcMA8K+GwA65GTVqkEiLajCYLtHZ18FBwOTOA08
+1UoSbJM8ViOJrbUhzIuIbJzJnYEZZsAUbsO6o97uFEaTwcOptR87n4thdqpnQL5frlYBXO5
bEVDIfcLZ/dQKcF+ZqbITHJk+5AZ3wd8jz9VJ6XgpMqaKm8fEO/smrie28tlwdVO7rh/sqm1
Pq6cdtYZuCGdH9Nz7u5CZfmQJYzQRFHzJsGFsBw8IebEaSUwB012JR7yopRuiIj4yptbesTd
BVt56+R0rp1t2KTM5HJzgDcSxcSAx2CZ4G2vU9Q7oFXmxT441I+mOpmYaMMh2yWOLmsWABye
cSfCovWNq/joyWpNSnPdULOvB6zm7iQ3oa5mDldoUpo0VZ06OxLm8kfcCpeEPughjgkvMKIk
3rm1k6nIf03vODGQXPjRU3SicQIysGw6jcNTqKDOIYMRdcQoV2QAUAsYvKoJ4nUCIK2gBqmv
mnLGSbMx+xXiTqV0iouICgCINAGBijtbQSYNkBDlkCLW4WJFk1VXaYOACXq4G9MHqnnU6Jrb
pbdySSA4shfBWUw3pJXWkPSYqQlgSsXpJfDPy0l6zcMgmC5hHU7TtzuSfhC3hB5Jwcv0LGmy
tl+8XdkDCUlB7b8OFkHAacytJmntrXaWrm49NEbf6ybJ+nL2A4iaHon+pkYicu0NktE1+YBl
7/gvwzb6E7RlvsgigQGbbBuc+zSxToIFodkIrzFqKQlOf7xV3CTp7bZ+VNvNsoL/o6iyxCsg
U4Fd+sAW3TgS1i/NlrhQETiruZtyz67OtQrSSoj4cfayVnUaBhuHiRuSabN4uOWHN+zaDVT1
x3kc7CrPbmEY7G4UYd8Eu5CNqTzm+qELpTSJHUzRJuQ885sFJCMb7BBkC7tSskhgItd+PLL9
dhFg35HVfkcwDRYkRM/ZHqCm8c4RStqUPUo5ptvlAunFHDYs2+aiI8BmGI2TMy534QrBVxBF
Q9tP4v0uz5HUt3DXnmwMcWksFU222a6WXnK+3C29WkRJem9rh2lclalld/Y6JCllkS/DMPSW
B18Ge6RpH9m5chmZvta3cLkKFj7LP8LdszQjVBk7yAe1G16vKL/bQdQRtAlugVtBUZ5Ga1qK
pKqYr2EAlEu6nZl9/KQufNMQ9oEHAXYlvHqXx86HcXNFAzAAfHjsz4ygYOCN4ixckp+xHn6d
TPVpQrarqBtcEq0ppLKrou7JfPt7iM5EXNCqdB8QPkpU1u09fu9h1WazxN/rrkItZEKnVpVI
SdqvPF9t0Z3Z7czMlQnrBOJbuy3fLEauAJBS8XdwvHkqfcILSQQ2l9TFAYgH/MJk12b0TslE
RXi5EeBsd27ido9AA6NYXpfUvRBo1OoS13S93+I694q22q9J2lUcsLu3X81KCqemsFkznN9Q
52pG+AUqN+s2JB1OroTMNphdkF0d5AFH3VGSqiaMejuiVn4F34I4WwodQajMZ9c0xKJaOrWC
8C/eNpSpib4IzniZivafxRSNeJ8B2nKKRpe5WNH5gg32nmC3sGLtS/DANNfLG8ptONl6Oa6V
T/GChPWDoe0wzr5OtXdQR2lVw/dL4vmwpRJWXC2V8GkP1N1yxSap0UTJYZhMfneCqg6vie9C
e/FBBqq69FPEa4i5uHMGSzqCNvWz2aNab3Ym6bAK/BosZyeFK8+7psFyg6ugAIl4G1GkkCQR
esh2HT4+xGzEmX2MVe3xqgApCCrscdQuVgt1ktzVTflQ53C+aC+L+NZnRG8VeyCirbYAtZlv
FhhjM8QSuErhWJS6XPaV1K+FeOD+aWCcg33TUe2vz+B7/6dx+Jh/3r29KPTT3dvvHQqRhF2p
72bwMogf6a2WR4OGIjWK0KaxQ5LtqH4452SMCoMvDmOhfjal50azddf0519vpAMhkZdnO3At
/GwOBwil3QbhsARBQANNYS9skocw4ervM+KENaCM1ZW4+SBd4fP3p9cvj98+u5Ff3NzFWSae
P1GXAhEK0KizHkzyKkny5vYuWCzX05iHd7tt6H/vffGAB5Ey5OSC1jK5eJy6NVJUEAKT8z55
iArj6aUvs0tTN4dys3G3SQq0R6o8QOr7CP/CB3VpJrwTOhiC9bcwy2A7g4nbkGDVNsQZwB6Z
3t8TXkF7SM3Zdh3g5rE2KFwHM/2XZuFqha/4HqN2kd1qg7/DDiBisxwAZaU27WlMnlxrgiHt
MRCaDY6Umc+1b7UzoLq4sivDrykD6pzPjsitvkc94VqLz3pUgZ9qTS+RpIalduC1IT16iLFk
0GFQf5clRpQPOStB3jlJbGTmxOoYIK0RN/pdcUiiorjHaOB7+l77cHFY8J6epHAuE4a7VgUT
uJQJ4oFp+Fpx5qd7NBDcADoUHHhf1xxgIF8y/e/JItBekkklWDoulJVlmuiaTdQ+4tmGck1i
EPyBlbjAydChJ0lnlAZykYoNZVOFDBNhuqQBRzkO7E8RCEBMKAtqiI6ii+sHtwDoOnNU0atK
uMoGJpXFu4BwTGAAUcYCYtdvz7PVbdFE55raitqvQ5B1EVWM8q3RchhclvdTgCxT2/RkfVid
qitzVOeEm94WJLQf+zrBBfv9gasYmrxFTgFv9XsiskLLOF2TSrE9U2U8JPqaOoHgWbCY+spZ
/zXZu4dwQ6ygbjrc0tXkfOAZW1Eh/QxCxIlahjE838RJRLitMNC4uiy32w1og8BKmUXuJpFV
Jta4I9zT4+tnHTxB/FLc+R4aQXdx2KgQx/keQv9sRLhYL/1E9X/fxb4h8Dpc8h0hwjQQdcNS
+yayfA05FZE5Ar1sFSNcsmhqa1PlFex/WS7BYniqmIqTZZw1BCUdWZaMTWtaQztsTAafsMi9
xdzJfn98ffz0BoFbeqfl7ddqW5XlYoe1a80h1UGby1S/0Uob2QGwNDWLk8TiFk5XFD0kN5HQ
FqvW40QubvuwKWtX78iIfHUyMegsbQOv5LHH9Wutu5q0WuIPPGUxevfMihsz4ttUzemvTrJ2
XadTh+F/yDm5K3VEIrp9R26OeC3z4mNBqB0LwsNZ3pzilLDcbY6Ew3kd26ORVCt0DIq6xp7k
01h7ED5DaAdm8ZPqXpfZT63q971JMK6fnl6fH79YogR3TBNWpQ/ctplsCeFys0AT1QcUZ8nV
+RFr9yHO/LVxJmqHs3g70gEGHZMF26DR1HYKd3yFWYTkxirqs+hTgg3Iq+aspp18t1pi5Oqc
1yJLWswa/3yd5HES45XLWA6Rkaua6DIdHAYCGVA9D05IaHrlBgZ0stIbc5+7XoaoxY8NUjcc
ou6ZG37NIakFPToG85dvPwNVpegZqk2mEZ8BbUHQ56moMT6/RbiBWa1Eayb5pb4nlmlLlpzn
hEJKjwi2Qu4od7kG1B5872t2hGb8AHQWVhFaxoZclfQRq8gHmaqBHH+j8yLobhmj7CCK8py7
D/tb53AWW92nSxeKyVYZ1bb4o8UuykwopiePwQvAVyc1hj8JL2IfrkPN+X5fDAVCOTSUbxBT
qlafNM90B7VJex+VjrdPkyQFagkGtCuDqO7F0StF897F4TAkq8NacQKx+zjbJzaw3yiOBo8U
NMA8Q7iB4NiYD8mO1q6d3Dqv7I6jC0TssZ9q1d1YeMaObYQ57SrqE8IRjc9ggmWGZym1QzZr
Okp3B1gTzCuvltSFoex0IdA5T9bfuklfqYCgiu1Fwpp1vVu6SiDwG26OxLMvy4/8lPB7M/L4
GuPqT0nwF0nKwXESUhE1wf37wE2k6cNoKXdhIif6opud1Rki5Jbn0XwAccRYxm8HQzMhM5dc
MRFVcnT82kCqls2J/FC4yWrulcxpg05V5yb5FqDoGS6BV5Q2yJ0b0RQILD0W0RCRF9rTXxIg
5oUXfKPkdzKD9N8hrsV0gEhTvAg2K0KfoKNvifg9HZ1wgqjpWbzb4FLmlhx6GkQ+vcmIQwTo
6sJJZxaUYz9DzAipgCKCNztCIqCoubZLoytlzNiaY4m/3AJECrnZ7OluV/TtipAnGPJ+S+wv
ikz5A2xpZTWOT6n92hFzRPJs/IyoF9bf39+evt79CqH9TNa7n76qeffl77unr78+ff789Pnu
lxb1s2KzPv3+/Oc//dLVlUwcc+NWe8qPn48lNLQAlmTJhR6eghb967HnMw4FzQBko4iqFtmo
+I76LPmP2sW+KZZGYX4xy/Tx8+Ofb/TyjEUB4tkzIVTV9TXhCpsUxDMkqiqioj6cP35sCknE
PQdYzQqp2BO64bVQNwdPdqsrXbz9rpoxNMyaFH6jsvTGS9+dZyfkoPY3r/+9gM4uMaUOSDOH
wMUfHTKth8DOOwOhjiz71LHyrQhmmTC1kSUhCThJTMmrLN1Y2iXiStGcEaW8+/Tl2USvQgIm
q4yKPwL74Hv68LdQWiIwBzqWSFRcqMlv4IPz8e3ldXyW1aWq58unP8YnuCI1wSYMG81kdIdj
q9pgzFzu4MU8T2pw3apty6AtsmZZCa7TLB2Hx8+fn0HzQa1L/bXv/4/6TnPfqhh0zNqoglbT
Rc7rCleZhL6AGmK0K36emXjw7EKok2gqZcTax5IvU8eKwk6f0JUtwRQIoASjJ+sJMnBE4EQT
HtkXW7xtEavVXUdVQS53hB6ZA/mBUvDdv4PIiGD828pS9C5/9GG5o2y8O0zGbsGOuh94ILy2
XW0UKNwTIRQ7TFqGu+VuEqIqvVas2nTDs2i1xovpqnxk52PSpDVf7teY5tLIuYhO6Hbdkxir
t+TGHT9yWPTBGxUDfD6eK5yfGqHwruph8W4dELEcbAiu9TBAsmBB6CK4GJzJczE4g+xi8Ecu
B7Oarc9+Sd1Ye0xNemp2MXPfUpgtJf2xMHNxOzVmpg8l321nxuI+BI9m05BgMYs5sCzYnCb2
uyHeaKnu+BklHesqHpFW6z2kTAgfrT2kvpXTjY/ldibKKkQ5XWLLuQeAuaHM3OAWLU1s7tVF
jQin03XcLggXG5zxtDHh8kB44+lBm9VuQ4Rj6DDq4kcENughtayTc81q4ibQ4Y7pJghJ4WyP
WS7mMLvtggj2MCCml8tJnLYBcSnshyLKGOEjwIKUVPyefkA3M9MS2OfZxSLqED9LOsB7Thx9
HUCtsypYzsxd7fac8J7SY/R5Nb2NaMx+5ls1V4fo9GoDzJIImeBgltON15j5Oq+XhN6gi5mu
MzAi2wVhc+KAgulzSGO202cnYPbTMwPCC89t6Rqzmq3OdjszyTRmJsK0xszXeRXsZiZQxsvV
HN9Q8+1mmkFJM0IkNwB2s4CZmZXtppurANPDnGZUQOwBMFdJQtHVAsxVcm5BZ4RLGQswV8n9
ZrmaGy+FWc9sGxoz3d6Sh7vVzHIHzJq4C3SYvOYNWExngg7r1EF5rdbzdBcAZjcznxRGXe6m
+xowez/Ut48ptSuMmS44hJs9cZHOqCfDLrc81TMLVCFWRLy4AcFnypiQAPdMV5YEu9X0UCYZ
D9bE7dDCLIN5zPZKGcv0lc4kX++yHwPNLCwDi1Yzu6pi5TbbmemsMavpS5Ssa7mbObkVf7ud
OQNZzINlGIez10MZLGZ4AIXZhcuZctSohDOzUeRsSahA2pCZNaMgq+XswUQFQewAp4zPnKR1
VgYz24CGTM9WDZnuOgVZz0xngMw0GXxC8fI8y+sq3DbcTnP4lzpYzlybLzW4EZiEXMPVbrea
viQBJgymb0CA2f8IZvkDmOnR0pDpxaAg6S7c1NNbs0FtCZsMC6V2jNP0ZdOAkhnUDfy/2ojJ
x7J+1cKT8g/ICOr7ReDKWlqEPptdm4A2CQIe1EL66r4eKMmSStUcNClbRY8hxPPCB3cSOy8Z
QsqAij2EH7PNSTp6nOjYT82xgLj1SdlchUywGtvAAxOV0S5DewbLAqq0DR1ACMvSCsvTtOCk
an2Xj64VApxsJwDAV1njOyxDcEOjqJL+mzaAP27mh0xoLejenr7AK8frV0z50riy0p/iKcvK
QR3oFm6b8h7E+1nZT0db8UjnlAVv4lp2AHyhKOhqvbghtbBLAwhWTv/YMlmWX7GSnyYLw/ul
NwDulKb+9lNGoXh6Ql5c2UNxxt5feoxRI2uioujc38RoWfJBHuSoM6+Pb59+//zy2135+vT2
/PXp5a+3u+OLqvi3F982ty0HAq+LLFG1gilFF0hZWMriUNudMXwhZooQ48/NrX+rLh+K+ShE
BYYEk6A2IsQ0KL5O0+HmvrrNVIfxD2eI+EQ1SQeBB9MvGpGKDBRpJgE7xROSgCTiDV+FaxKg
RaghXUlZghdKxaQRsb1V+QdRl3w53RfJuSommyqinfoMTc2YxLerKzuoLc3L2GXbrhaLREZA
drSqki0MHp5HNbXF2ym9b9XSVzMDgWSwPNB1V3SSeCqn+01y8JRAZtfX8mBF0vMLOXLbxbgL
hkVSnulJp93cqdvRKgjoEgC02kW7ibbXHzI4ECgyMMkUrWPGpgDhbjdJ30/RwXH3R7pxatYn
5U2trOnRy8Ue/G+SoyP4bhGEPr1VuRM///r4/enzsKHyx9fPbuxQLko+WQFVsqfSZGz/ZTRb
uMLghXd9AM79CilF5Omeow6bIp4xFA6EUf2yv768Pf/rr2+fQINi7Dm1G6NDPDo5IY3J1Y64
EZWZ4MY0nxD/Q35t/bogbrYaEO83uyC74iqZugq3cqk4D9JsFWpegVIUTc/UOVUR4WmhFTGD
uUVmB/JmOVkDDcEvUB2ZeDzqyfgNrSVTxqyanOZ00RkPwNs9WflTDQpqUnD684Zh+3Bm1b3W
rPIVhVpoWvJGuLbXkESpeA4lg6UIHbbXw1FahQB7z/KPDc8KKnQTYO4Vu0wEqgZyGJZZSDyt
DXR6oDVdHQcTU/EWrDeE5L4F7HZb4r7eA0LCKVsLCPeLyS+Ee0LroacTQr+Bjst2NL3eUjJD
TU7ywzKIiJd3QFxEmVRarZuEKL6Z8LuliCU/bNR6onuoivmKCuyu6fVmMZWdb+oNIXEHukz4
RMAXAIj1bnubwWQbQjimqfcPoZpH9LoHngFnc6PbZrGY+faD5IRdPJBr0bBstdqo66BUVwB6
INNytZ+YqKATRfh+aT+TZhOjzNKMcEFXl3IbLAhVKiBuFkQ0e/1dDQhxafUAIN6tupqrtk0c
KbqIkNAQ7wH7YPrUUSC1WRHiyPqarheriZFWAAgLMj0VwCHYbjWNSbPVZmK5GN6UXu23cOLk
ZJX4WORsshuuWbie2LMVeRVMMxAA2SzmIPu9J1xvZRWTLNZQSpUcQQpEiIqqqT0DnB1296UR
h3d8ffzz9+dPqKowO2K+qC9HpjrWchncJugoz8fyLN8FW+vyoIgmvHVSFfjJGhOa+Cq9icuG
u7yZkTypLLbpVydEspI7CdXdT+yvz88vd/ylfH1RhO8vr/9UP7796/m3v14fodOdEn4og85x
eH38+nT361//+tfTaytjcfj2Q4SON5pN54seP/3x5fm339/u/ucu5THpw0zRGp4yKbtYDJbg
DmiYeUPH5DN+ry0J/AJGdJCMV4LbZQ9Erf6GjtmAUazMfh2oLYDQbxuQkp0YwWBbn4zLMCTe
xj0UoXM4oNSWQ2mWWKCLuprsUvxdaIBFsTosKJ3avloVv/E8R+fDzKibGfXy7fvLF7UtPH//
88vj3+32MJ4ZsNj4yFXDkXGIyw7SPskh4DVUbI6u2IyPybvt2lnJGK4Ed7OyNvHG9ItC9NCJ
65EZqAOYjyvpJKu/03OWy3fhAqdXxVW+W26GTpzroA432u2s63JxzuPRRnMS8bibT8K2dhXx
oHleV0l+dD1VKzrlr+QMpY+7CErsll/nXuHPp09gLA0ZRtdvwLO177pKp3J+pl1MGUSFGi1q
GqzyUZGQKPBTSNPPlRfhyO6nznO7kyVK6qJsDpiRM5Dh5Kge3A7nJ6F+Pfgl8eJ8JJzvADlj
nKUp7stNZ9dHJVUN39MZJKqhPRZ55T0ZDaleq5yvJZmcJKeJZwHtkbFrtKZ8vE9GPXNMskgQ
VyJNPxCHMBBPRer50XDI6nOjSWaTH0aT6Mx1YD2yxCtL1ZQgyReRXGWBR3TVjXmo9HuZ/1mI
e4MfW5pKuKoC2nsWoVHAgVZfRX5iuTsx7pNcCrUVjCuRcvrpWNOTvLhQYwvdhi30Lh1+lBjT
1gMOB0fGopKrc6Z27ZLFS2o6Auq4V8w+ukaBej0lSSq9ws2SU+M88pznQVIIfjlBfzgoZoXe
w6rELDiiz0wMG3VquSOUFeCCYbxSwC2UmN40czQCmqFU4uh+RzHddmBESCpZDq+XaeF6OLKS
pzaGMslVh+bY4WrINUsf3FBjOl3tmMBfkMWCy8UKVhV+LdaYSoDDYHogVAETK6wqOBXzG8iS
CdxdjyGOIivqZLCfIL01aUSdMHprU1Q1cdVRi3qO0ohzDiFS/j9lV9acSK6s/wrhp/Mwc8YG
Y+N7ox9qA9TU5loA90sFbdPdxNimA+M44/vrr1IqFVoyC5+IiWmT+WlfKiXlYhdcJNQcmIFL
Qq9khnuQjkh/54Qrqq/Zg12aTu+bFxUjtw2+mZZRZAkt1RzcKiQehNjU9T9OVGQ91yDMNHmJ
H9jl3t332VozPnmJWn7jJ0S78YrW13DwDR707SBSI6eZE0bFQmyJ7Rh6yksNInmppxtcOgQX
3o6EmOuEFqFcJbcl2RmeHEIYpXTVFn4lWI+dtZOX0IpgfCelchQ35RxA54tn0fm304vUGpvN
A9bErKq47B6lXMayovecHnM1oow9YdKEp8K5VzbzwOxPE2aFKJaBhFK+aQYReBBuj72uDkay
e3vcPj9vXrf79zcxIK3XdHN0lTJSe/SxiwofUg8ehhKWZgW+mYpOqfCnwpbXrOYMnNuW+Iap
UH4sTpllZU9vve38EFDWfKtMQ6ko9mWosy2LTiCtxAD43tTpIjFLwflIcHI+EroqPyL9ze36
8hKGimzBGiaGBdDYUcs2R1dQC9Cy4U1uqgrhVhDwalXyowOWFpkegj4tcYNuvSr9ziPEqKzr
4dXlPO9tOCvzq6ubdS9myseX59TTPxnaP1lXVbedWV8zNFx9ytlIX8YQuLGv1sXEu7kZ3932
gqAGwrQ8seSFbo61SkvB8+YN9TQh5nVPADfhHYwQs8UMD+m0VeLeOKZZFf3PQHRBlRVgkPa0
/c23vbfB/nVQBiUbfH8/Dvx4IfyWleHgZfOhPB1snt/2g+/bwet2+7R9+t8BuCbQc5pvn38P
fuwPg5f9YTvYvf7Ym/tNi3PGQpJ7bPt1VBvahRjvLi+v8qaetZ0q5pQLMTK+E8JkZTi8vMR5
/G+vwlllGBaXdzRvPMZ5X+skL+cZkasXe3XoUR2WpT2Ot3XgwisSOpqbQrU3Aw3vugCXMHR0
lPL+8G+GxJu8WHye+2mCNcFeNj8hlAfi9Ezs42FAvT4LNpyDqHM8B7CcfkMQ6cXCDQmXgOLD
tyIUAVomHVASPAeAD+Xe/fLWvP7tukW4dCS2COlLEE1mfuyJ9FHCCNWLlksY94vtKayrGj8t
yaoty4hetwXLKDNdEYIzmmUVeZEgED37r5qywcNtQOiOSJjQsqVHJaSP9uILVoVMeKCn+wiu
E0M+ujERY0GGOeTSi7+c0dODUMoQm3nhcbGv1w+7aEq28gre55hvPZFN5Ap60RwiXYrv2JSt
q7pn8bASHgKmxD0wBzzw1PRcib6J7lzTUxFEIf7vcHy1pvegecnFUv7HaEwY4Oig6xvCVk90
ODhY5GMWFaL9PQvby8pF9ICuwPzXx9vukR+u4s0H7iQrzXIpJwYRw5W81OYwsvUdtFMVUY6Z
ycwLZ0TAgeohJ/TDxEIVLrPFEye9o8c5I52Z1it8xBJKyyVK6OgJcLzhKwovyQv4qadkPuNn
MSr69ZSlzPdSTOSM+Dmbf+UyONyUQVFrYoJgOcc4oFqY1gW40IHX15NgOpKMzpzNo9LKLLod
D9dOLmwyvLsl9DckgPTm37Kp0I2SHY3soGkmYD3C1VJk6vE1GnBNMm+FGuWLk6a/vmPKzUib
6YgusfQLxuf96QVYUhdrtxJXlyn+JRDsPA0xR/5FFTRGUHoggE3rzeRq4nLEq7RJmgf88PqA
E9X79cXh+Hh5oQM4s+JnHTNVS7RSde0ACDUDgZcuNYfnBYSCRQJ2AZCfPKbdDLfpeZEFCNmK
m6XTm5pFwggI7X1R62LpbMPd9RHUFNlaVTrP98ffIuJC7wSKsm/4i/kJsp4QqosKEpZ8m8bf
ynUIYYWqQW5u8Q+hgoBVyB2xJhSmKMfB6Ew+rIz5UsdXs4khnH0o0JpDcDUlhRBG7UQsYAND
6foaoNFnQJ/BEIqKXUdfX1VkbFAJ8e9HQ/xTpRDlaDy6I9znKMw0GVHOcboB5fOPcG2lQcaE
fzk9F0K9VUGiZHRJmKx3uSw5pH/eFMvJhJDCuo4J+XKZOIsaHEqai1rfNMCtbgoPI6xTHuB4
8Jb4ic0gLEfDUf9U5tNiePWZ5t+Z5z1pTPG8Of7YH17o+kPyIMlKezNsV/6Q0AXUIGPC5ECH
jPs7HraYyRjcgTFCXUBD3hIOaE6Q4TUhSXcDXS2ubiuvf8Ik15PqTOsBQnh71iFEpL4OUiY3
wzON8u+vKXcf3STIxwGhhKwgME3cM/3+9U/w9X1mqk4r/pe14DuVnXL7+rY/UFmEYNKBvwBw
ll9P3Wt/cCrPD3lGnJCVoBqHwjY5dhCxctaE8nrdewBG7SVYcd/4Dzno8CVe6s3MEKoiPKx0
FY89a9r+99vgCEmU1g7RiIByorVyvMPywaTZfE9oOU6gLqvwhGVIKiDz/QCeeKOeZ5vHw/5t
/+M4mH/83h7+XA5+vm/fjtgT15wf5YolOkDncjllUlbejKFG4MKuur1ZV9U1AhsEYCKJRgjQ
EPMQf+z0yrrkh+7c0o1RszoIfTNGcuvVz2cZXlbLzyYT9IAg2IVf61mqIL9uLRxITwS/WR42
uYjnxPdY4t02F6dVXOYFY82+Tsz5khAKQn31hAjzCwjaRloPda75Qs9+He6Oy/BiyhdOnOFX
O1EU5b21EGN6ZkbkrFkRvqLhZb/yit52ZuWcn+gbv2qK6YLFeJcq1Ly/qULBzI5vYmGWfkWF
RRTvy70F5EmPKjvzEwibjg+WVBDp7Wu4bGxmCXEpKytQELdZrUsEUMbglDQK+mDQCpYT7kFr
EfgFDoKj/iCSIqc6ZRWZVxKvz3izF5lUdeFnQj+fDuUg9J44HmKvVcxDQyBBs+D+R98RgnmR
JSfn/vjYJnwr8dIMr6zKKF7AYZd/Pha1Hn0OHAlwHrg7yD099pJUEACeknSD/cvL/nUQCKfd
QtEeop/r+/8pDXTH3TXhgU6DlWw8IhxLmahrXMbTQEEYRLeXuAinw8rhJRhZWZO4U3VG26ht
jisu8Kd2dBbZCSJRuX8/YGa8vOxoWcH12XikGd3Dz6b1w35C+nHYIU91w/LvrIQ9FvvZ+pRL
HhjCUxuTKuEYTODh/VNrN4zSeAWcy+8eB4I5yDc/t0fhIr7UPvxK8/sMVFsMoiRxETQlduQk
lKi+XY7mc9GtiLBI8MX2ZX/c/j7sH1HBV0RkhesjdF4giWWmv1/efqL55Uk5a+75xGtm4jq/
IIL9SKAUyPCijSK0nQ5U6uHb5h5heSP+Vcr4IhmfzBA5ZPAGqlY/+Bid9EmkEc/L8/4nJ5d7
U5pXJjsIW6bjGW6fyGQuV1rhHPabp8f9C5UO5UsVgXX+1/Sw3b49bvjEut8f2D2VyTmowO7+
naypDByevO5b59f//OOkUROPc9fr5j6ZEfFpJT/NI3SUkcxF7vfvm2feH2SHoXx9kkDYEWeG
rHfPu1eyKa0TmmVQo1XFEncKfZ+aeposKQT5aRHd4wLeGsQB4qOXZAXxzEIYmacV/hS05F9Y
6vkoX7lx0vgeM4BwPK52oscPJjNQTuPCQFp8udLG106jVTcHSx+qAiIwBdjmVGAURLxITxGd
mnz+wPff7zKCkD68rfULxPVAM/ODpFmAYSe8eJIoiAqSr71mOEkT8ap5HgX5oTPKrKqWWjjX
IqKsJYEbSCffHuACbPPKv5D8O7477g/GOVWV1wPrrsvM0x7/adtKamcdvhODWXzsvhF4r0+H
/e5JmyJpWGRmmM2WJAL98hOsI46qPbXNqjMNYH66DJnwK6+GrtWQyuEtpaOmITCM30HsMU3V
CBBVpeWj6/1xZj5NteSiUEH7sGihp0kg/IcTKdIE8JoC4cUiWNVX1AVKBayKKKdV0QinK352
b0byHms1OB42j6Dwg8UrrXoF/jk6PkiW2grNKQWLlMFb25LxwzDpXZdlhAPSmJEueYWGXt9h
KgA7B3tDUfdpplczaZK7419TuUY1uTYMvGAeNSuwq5Av4Nq1lRezkB92mmkJobZKfSZwEpfi
PO0swjf7YaO/6rWEZu1VVeGS86xka15m7LLKKKgLpofv5pyRnfmIzmVE5nJt53JN53Jt5aJ/
167J19CvfmiEZYffJJgXkPhiCLRnz4jxrp6WjakE0JFFbEokrw4AYnBjxm3U8rTHQ2ch/aCz
sb74KljYdZ9swYv++77OKi3q6RovEsi6pgT8zlJxy2lpVmgcOACzwmSJXjdJXslbAzdrlelj
lB9nhng7skCyTi1RlCYbBj5CBj+l2iSTdBkFKPHKRWw6FNTZaAX8qrC6UlGMzjsJAIorg5jC
RjIrKJ2WDlzUaVN6KceJ13IiCpRA0zq1ki/7+Exx0bThnxY2xauVspgckOnQ6g5BgE431nYL
s6e7IqNdp5hqouPS2rDrW+IMLBAsk5HmaYQ0lGDpV77FM9REDzpb/+TK3/yjGRo0dPuCuwBL
jailcXECIrplOdq7LI7EjQZLtaWTcCEHVAQfCD7PNEqD4iGvjCiy0zLNKj7GmtBgE5gkCLew
xlB4koFUUe0iHVYQmjSqxFG9Cx+Ni7Sg+96mWHlFygiPyhJB7duSWxWRoXh+P02qZonFEpKc
4anZIoOgil3KKb6uki/rKpuW5odL0sz5XoNJtTHggaV/qnYcvvDAI7JYQ6d9qKOC0SgrIMx9
yDCVTwzpxSuPy0FTfsjJVsb2dgKDfIwLQhpozSeEaN45YBLx7spyV3sy2Dz+sryNlOITi18Z
SrSEh38WWfJXuAyFtOQIS1zIu7u5uTS6/WsWs0gbrW8cpPPrcKpGRZWIlyKfWLPyL/5t+iut
8BpMrU0uKXkKg7K0IfBbGWVBwPYcrCWuR7cYn2UQDo+fWL9cbN4ed7sLfT2eYHU1xZ/j08qR
Bk4yKd40efB7274/7Qc/sCYLaUZvkCAsWp+KOm2Z2I4WNbIKLh/WCfZAKJDgnUtfkoII/QVm
YIxvfxYrmLM4LCJtw1tERarX1VJ0q5Lc+Ynt3pJhfbnm9YzvcL6eQUsSddQmRSRdN0Zcdte2
DGUeOGMzeMUIrFTyH2tTiaZs6RVqp1Dnb3e0uqJZKVUBQJ0wSozdKCu8dBYhE0RVMOzhTWle
JL47FHdOJ+QsaT5LCDs9dfV7qkOzgsJLCFZ5X3vlnGAu15SQnbCUzx1rI096mpzTvPt0fd3L
vaFqUbRFaqcGQQEfOFEIPm98841EsrPUpudgCBTZv2HfieEcCl/G1s/IaYlLSPwt69j4d1/h
rj+LmwefQk6uh5/CfSurEAWaMK2N/Z2gdmMH6AAunrY/njfH7YUDtBwNtXR40kC6eOqIsyaf
T24jROJDuaQmU03NJBW02NxCFNOaZPBbl6nE75H929xZBe1abx1QypWHfRQkuLmykzdaobmo
lRCKhRN8i2NPcIGOo7We4sUur2FJHkdJlFbCVUsDznSyxGPpl4u/t4fX7fO/94efF2YTRLqE
zQonGkK35rKqSU0BERKC2NgaHoQpOiYtCL5tUQwgoz9C8xcfEafHQ3tYQmxcQndgQtl/sRNe
wASBiek5jOr0s7izh7JZITQU+OE109oO9bR/ygZp3cib7BqCAMO25y/rtMgD+3cz0/eFlgab
LJfaUj422gabB+ArleObReGPjUOBkTpkpfBLxlJx5gUTzABMeoivVJuIvAAIonyOr+yAWWcT
pm5KMNMIwQV1udWpZrZWncCsIm/R5CsQbOZO9nUOPq2o7C3xStCELObkw4eNykRdMZkJBJUI
bd3xhSgKDqIIYUEA0VZoYxl6tMhE7LF3ubGLip/4dYhkYZchaurG+l4Qa5+c9+OPyYXOUUeP
hh89jFWu86iIbyaICLdngCaECbEFwsfIAn2quE9UnHLRaIFwfRoL9JmKEzYMFgjXzLFAn+mC
G1x5xwLh6tUG6I6IZ2eCPjPAd4S+vgm6/kSdJoThDYD4iX8yGd81xJlYz+aKMm23UdglEmC8
MmDMXHOq+Ct7WSkG3QcKQU8UhTjfenqKKAQ9qgpBLyKFoIeq64bzjbk63xoigCFAFhmbNPhD
fsfGtZuAnXgBHH8IzV6FCKKYn9DPQNIKAtb0g4qMy4PnCnsoWByfKW7mRWchRUR4UFAIFoDB
O26P3mHSmhHymd595xpV1cWClZjfRUDADZa+XMKYMORPWeB4bVPOivUHVam5tX18P+yOH66J
BHzl9Vuih/J0zXs6Z528xXJEwdIZcfnQZoFfP8hr+CikIZzRhPMm4+WJwwIVeFB+9iEUaykU
WaqCEW/Rve8liokKI2K/k8H2+NKLPfP9QOi3zr0ijFLeIHgigBvfU2g4vfccGP7wwkVveG4o
s7ogXghEmMFAZAMeeOZRnEfYNbi6DT11lG7QHZfJl4uPzcvmj+f95un37vWPt82PLU++e/oD
bGN/wkS5kPNmIQ51g1+bw9P2FRQQTvNH2nBsX/aHj8HudXfcbZ53/6c8c7dFMdCC5rUOFk2a
pcYF6CwImjyuZywF/7t1UMUgL0PT0KbjcP+hiHCjix58Q8msRhrwz8WToOuLaLVi053WabPZ
y7F7CM4KebDUX1SEFZN5qyxpSZQE+YNNXeu3wZKU39uUwmPhDV86QbbUDhqwPuFtXr45HD5+
H/eDR/ButD8Mfm2ff28Pmt6xAPPOnHk5s/NoyUOXHnkhSnShfrwIWD7XdTtsjpuoPW25RBda
6M+EJxoKdK+0VNXJmnhU7Rd5jqBh03XJJysxlG6oc7QsewmhCbvTtXhRd7KfTa+Gk6SOHUZa
xzjRrXou/nXIcIl2X0d15HDEP8jkqKt5lAYOXbh2ebGIJUvcHGZxzfdqsVmCqZfDj1K+5MGZ
gnzxef/+vHv88+/tx+BRrICf4H38w5n4RekhvR/i3kRUScE5fhGWbjwv7/34a/t63D1ujtun
QfQq6gVxJ/6zO/4aeG9v+8edYIWb48apaBAkbpcECVL5YO7x/4aXeRY/XI0I0/duzc4YGPZ+
BkNcEWig4ZiwrzAz4n+UKWvKMiKuMKxy/xs8r8In4UlW1OXNNX5csjCfy4zX9XxuAPp8do23
XKP3V+1Cie6Zs/Pz+Tf3+Dd7qdaCLyxDXvZPuq8MNVn8AJtCU8ydpWJW7k4WINtPFPgOLS5W
SHFZX3G5rKJJXFclkg8XPFcFoQ+sdrm5WhZnB0GD2qPgTD1wq1rVri74fPP2i+r5xHPbNceI
a6wHlhIpX/V3P7dvR7eEIhgN3ZSSLJVVcSZO5SMRY18TzqyuLkM2xSaS4rWJ6WGeOTes7fB/
YhfrxglMgM0LJ2tdhddO9ZNw7NIYX0JgXMrc7iuSkK9MlHxziZH5loSRR0MXXc69K5TIJ2sZ
jZDu4UzY8gS7r4s4bnw1dHFYblgNeGK89P5Sk342KDj5aGBNJR7Miqs7dz6uclkfZAo1Yp41
KesmuBSDd79/mQZ36qOBbSSc2qB+5jW+nGuIFFzqhVvMtPaZu1N6ReBmxA8QqylD5GDFcB51
bD5Rw8ADi1DmkYxzCdsPLN8UT0hn4TvY4dnVGXhlRTUKeO46FVSzIi7Anc+C2pcsRGcFp46a
KIzONmSKC82LufcNOTeVXlx6YjOgJLm+NaQwZytlOqHviEUepW5VW7r4RlKdpDC980ADYRPA
3TB6WlBF7pytVhm6SFo6NZ0Um2iayW5GK++BxBjNV5bQvw/btzfjEqWbQ0LLwhWMvmVI700I
TzBdot7OFDomfQBQGXFElmLz+rR/GaTvL9+3B2m6a90HdZtZyZogxw7gYeHPLJcmOqeVcpz1
JXhUtBEdxEVQepoAwin3K4MoURGYyeXuWMJpu8EuQBQDv5HouOXplgA7yAtMQSgC2zi4RqEb
Jz5xpu2F4mCStbD28kLbIB2DBbbNuwu5Bx3N+eRu/E/QO68UNoAAxp8C3gw/hVOFL/HrQqz4
T0J5Bc4jU8anz7oJ0nQ8XmOG8hq29fPTXW145UOSRHDFLe7HQQfCuM1TzLz24xZT1r4JW48v
75ogghtmFoCuVmc1dbrjXwTlBJTQl8CHXCQGuxrn0Fu+SssS7sjxrG6lh13LiezpKpvN4EY8
j6SGkjC4gJpZii1yV9wejmDmuzlu34TD9bfdz9fN8f2wHTz+2j7+vXv9qbt8At2spoJ4KPKp
oTDsAVx++eVC01hq+dG6Kjy9x6gHhCwNveLBLg9Hy6xPsR9QsNLF/kSjVZt8lkIdhAHBVH1L
4t33w+bwMTjs34+7V8PZpbj71e+EFaXxozTge2yxMIbTEzYVyETw+bSOwF2VNtWUFTAX0dMg
f2imRZYoGwoEEkcpwU0j0OdmuiKHYk1ZGvL/FbwPeRWM3SsrQoZFGJMPSl7sZgZ+sSyLQcWy
yEJRGRTOgiRf/39lx9obtw37K/24AVuRtEGbDcgHP++8s8+OH7kkX4yuuwVBm7ZoE6Dbrx8f
sk1JlNN9CJATaT0oiqJEiky27EvVZrmDga7MOWqkFJylKQv7AjcBgVn0luaUnL6xMeZjsSgr
+mG0v3rtnKzwqN1lZe4GFbURQEhk8c258ilDQpoBoUTtIbQYGCMuAk27Sl4SbOetUkFZxPOl
hMQ9V3Cvr90bgTbap3W1Tp1baAL3R1vJolJP9ZI+vXZpmmnlZ2q55Xe7yHsqFvjLO8VbLBZC
nX7bV9qmjB64Nz5uEUmd1RRGbaWV9duhij1AB+LerzdO/pD0NqUBSi9jGze3hVhfAhAD4JUK
KW+rSAVc3wbw60D5mb/gpf124h04/YxdXdZ4GnjQStGyfa5/gA0KUGzeZU1kito2umExIbf0
rk4KEFdX2UgICwglC8gk+QSdi9Bvc7RkFZanklJ76haFUcRshZzvVMIQAFWQldl9nYGwKE3b
sYfTCovcaVM7FHVfCj5B1IQa5hvG49/vnj4+vnj/+dPj/d0TJm14YPPpu6/Hd7Cr/Xv8XRwQ
4GNMYTtW8Q1wz8WrkxMP1OH1GoOlLJDgJmvRCQWztKgyxqqq0N01bKRIVdqQKiVoMugQfXEu
nDYQABp56JFetymZ1RaycfwitlIJId8MY2vNa3opt7CyjiUR8PeajNuXjmdpeYsuDrIKmGTl
Q4x+1NTS9lc1hRUHvKZMghtQa2TW1yHpXuE2bz/JrPF+wHU2ptLz73InpCJKg4VpVSXTYQiP
unSYFFmeojZY57EZNHAUgTEvh27rvGz3kKqki3IXgbwCDlEp3OY7WAw8P8JLA4erTsOs3XnK
me1tMem0VPrl6/2nxw8UC/ivh+O3O9+HhxS/3dgXlfPGjIrRR1c3CZu8zGW9KUGLK2cj99sg
xuWATwrPZiYwRwCvhjPhE4Te/aYrlMZM2xFM7rXFZ9nQKTj2+brk/uPx18f7B6MVfyPU91z+
VVBq4W9ycMZzsNIPkwq7GvA6Ed9RC15soyqjd7kglM7O7eluQGhjHJBAHL0WDuZUMWAFnLlA
q0yxgrguNWek6RG+kO9QJyjeczfnuuoG+ADlVoHhB0JnEa6w46cE+Diuino1F7CLQiTA0AZi
lbOHjwnK4WTwNT2vQSAbl/isRbGmH3p+dEJnBsREtXiwasVpRhTOrlA8sxcn3081LM43JNUE
7DQ/K3FL8SHhtLkZR6D0+OfT3R0vWXFqwrRR1z2mFA6EmuIKEZE2AxWHqqkP+4BfFIGbusC4
qatT3XA2MS2NKSO0NWYR8zLmMLCO8dVJwB2vHOIJTR8nYdCLCqV18qQzBAfhjU5XfvsTZI2X
iQmHLrTpM9aVFsNylv4Gp2j7wQ7CYQGCJOTQYeT1JriRCylmAJwEx6xt69Y845Gv0sw08epA
RSxILOruLupkPs4koQFQqUhDv3hWIkCpkD8g2smoYh5je6Ta2Z5j3DzUBcUcXWJs7A4AYG32
thjIzL35ofZflJ/ff3j6wpJg++7TnSXPMUU0HsOHBmrqgaZqLih0wTRYHB8D90oYdWXt3AJL
q0t0GYHjFgPX9lGnc+XhEkQlCMy01i94QmOTaxtjIYPsrfWAGBYcxe8AAs4G4jDxId9cTMk1
3fAzXGjfDVPZFC9moTZh8lLDvKRexB9nWrH9XZY1jmziCyr0LZk57MVP377cf0J/k2+/vHh4
ejx+P8I/x8f3L1++/HlRdSg+CNW9ISVr1iKF1lNfzXFA1K5RHTi0lY7jcWros+vAczPDtErE
Vgfl+UoOB0YCKVkfmsiNAWb36tBlAR2DEWho3mZioUyZoEqYFl/EGbqxbcJosBrvUUOwPjB9
muOKtwzIfC9f6P+fSZ8qZHEC8iEvo03nqB0ElOMg/QRIAEoVGi6BXfn2Z4VqO97egiSDvysM
w9dlCsFCqX6NPH8G3mnHQwZNO0bnN5q0MDCM92wri2yFSwZLIZmIqM4VIOOWkyvF4Q9wfwLa
A4kn8fLmRCi7+G0wvBBCs0s1UtMUltbqv7daLo0u2SpapD1pxKKggKFRJRCoDgayrXv0+eZb
jykcpnZ01vbvQl4JNdXzm/w+68kcpOEpjebDnrVvt9HlWGI/CpaskkdF2ZWRHpoUgawThqQF
YVTRDrXGy8HRCgmIcaSYAcJN5CgJ1NqtfssDjlvBPvTcGe9k98lNX4vrETKGLoJBedNcN8ye
Mn4JalUzrdehmzZqtjrOdIrNJ5kUBo6Hot/ifUnntsPgimIokn9+mzooGAuGFh9iguq/771K
0Fp94xQmpjauegHyUCiyrNNv7kriBMjA3SEe8lwOn3ILEL510YOrCRcgp1n0iCaqMi+qMdrB
Am/aLKvgNAsHNHWsXnvTLa7bkEFU7pycEQd5IDT9QuuY+0rE0PZMAIK2mnuVs1Ll17k9AIeb
cm0JGQ5ndui8Ge32kZNr2QHMhw2b7DGmXt2iHkWmWffhzlQe7UGKRWjz5A8CSs6MDhy7ishK
ZXC0UwTaKXjd0t8dNBFnhuzWkUMCUE+GDgcChQxOHVOjTe6VTQvZLddrCMmE58XBzHKGghZr
YMfM8DDwWFuk2qgCwmQRsIaD+gi2+iZkrsFkPopkwAVlWxzQpN23xWbj6CxzBeGks8v6XkzQ
uv4gZMaPY4ZGqC1fuqN8pqcwzVFJxhKcmRDfX8GsjPU2KU5f/3ZGNgG8GdBs0zA9sJFSo0RW
9n9aDiy7NBA3mHwsyJegqwOBLQklCGUm6mSATRUvXnZU0OrDeC2ZuMJwCoGIxFtHQwMOCKYA
R/IR5s3ZcsKQQa/F+7bwLCJRttm1G3PNoRrf5LNRRpdaE16XBJ51shcMYPRqggwCG8eNB6vQ
GBYenKqgGDTHQOZswhiGYgXKNscwHMVJHsqLRBgtWtfpYewKaUO+eAQt0ihEinJXeUO+qkI6
Ko8XVT58VusSsMllVeQzAtTTxYb8MC/aCk6RmVOficHn9m4IGTUMa9CTXXIzsqvbVXXqVYYv
OmHPX+VJ8sYJPESH78NLmC5oR7rlhZ2gHRpXr1724gjDPD1zAblJLcMh/l67Wx1iumlEOYPW
iai0LlgJqm3M9NViZPUtdqAUoM2vMFF5MmuH45fhBkebI+tqwVcQ0T3XHP3JkCVTHGVRWxqn
K+vGWpaPabzRJ9PComTpaaxbACg7XR+UVFlejM2m98JHugdnTfqk9QDLeHrZ6t7dlTGZSnU5
vqTbCXHJsu0rt3Q4KHTGwLwEKwbrop7245smG0+uz0+Wq0wXBjN/qsN4iV680qGk4L72YNTY
P3LEMyDT5euM4YsEHwdbVa9+pninoosXJ+7csFE1aqPAbWDSKBGCnTrokLgC31fF2tTwDNKp
vbG0Fc59hnt0kD+G/YFTUtStnYlzKmdrKymEAcPXjLoZvPCG7jt8Nqf/B1BXJPaavgEA

--LQksG6bCIzRHxTLp--

