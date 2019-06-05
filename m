Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6402BC28CC3
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 02:54:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0CA5A20717
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 02:54:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0CA5A20717
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8B0866B0266; Tue,  4 Jun 2019 22:54:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 861126B0269; Tue,  4 Jun 2019 22:54:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 729FF6B026A; Tue,  4 Jun 2019 22:54:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 38E9A6B0266
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 22:54:04 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id l184so8768449pgd.18
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 19:54:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mime-version:content-disposition:user-agent;
        bh=a6+R/Jw+NbYrcR6pTAkeqEBdEHZu/iGXisfeoLthZaI=;
        b=iKNSgmds/JAbdScEV13LAIoFeO3Rsv/R3qiuLqCo0gGjwCNv2wrHtSLNBPAh9savrR
         Da5uKAljwGqnYhv+XEdXjatL/OJ6CAr7xr8xTTGS7KZWblnOlJdWItxFbr0Mz2BwPRrE
         iBYifRE2wgtDOqhRcsRmRB1utjBhs0SSfGe5sOydcKR3+nqU3ST1D5rOYSsUzbIBKFnf
         9ReyNBrSCDXGrIoWwrulInMehmC4MxeKCUjWrbcV2cTnc5u3eepFzgOCi7pnEMjboEtS
         MEIFemZPgKGn43boBrUKngrjNOjzRAjnQXa4uBV4kXwY8V+9ZCDgroqX3OnioeEiZKzu
         MxhQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of lkp@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=lkp@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXWmMdphPZxgYZbXaw3w/wK3obIZjZOS+VsTUGuRT/FEGYph6Tz
	WFDGohYSmJ2BZm7ayEjgIQWvrEf4CfqbEj/ymbi04SsEaw2KCoYH3ziKL/ITthJt9k/eKhw/PhJ
	AJcol0N2dKP8vAVXn3sMOzg+wVH+5m9xDUAcyKy247/8KAUTpKh/V3+cRTIABJ88sWA==
X-Received: by 2002:a17:902:2aa9:: with SMTP id j38mr3578445plb.206.1559703243680;
        Tue, 04 Jun 2019 19:54:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxyFEfbGFBqdmQ8SU20kgn3W0kedt+Nm2KiVJ450s4DgVa5w4jqBM5YxpAkQHZOFAuPlNFT
X-Received: by 2002:a17:902:2aa9:: with SMTP id j38mr3578358plb.206.1559703242052;
        Tue, 04 Jun 2019 19:54:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559703242; cv=none;
        d=google.com; s=arc-20160816;
        b=FepNlDL+IKF6Hk5BdFba1WOie/31nlXfAKkVGGdb2RPsMxlhtMTfbBs5syOushBO0A
         aBDp4thpyVr5j9r6LGdOj7jxmJxXij9042NKgDfdO4PJe7PEt4S8RCsgJSpChK43oEwE
         bcY/Uh44JNfD0lQKd9oz+Y0zJrFw4lLaAG9nWw/5RMJLvKolqsI/3oImzQFtWdgUCZCm
         io2p9+jnDFef7x2+NGgal0hpMYwES5hPD5qiycbas3J6YbiIokiWLa2GHLEQjWpYBHEO
         j4HMj4ao/gOpmF1xxdWZA35wFNl0fZvtI18xEV9av2LB8s/GFdGy3Skk5RnRZeQYcLGO
         fBLw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date;
        bh=a6+R/Jw+NbYrcR6pTAkeqEBdEHZu/iGXisfeoLthZaI=;
        b=Op3YaYKbADVjuY+vkdGXNLpau3Vii6aU0nUk+QBy77MuLNWWAwP18bz2AXLT0ngTUg
         pTRt4GATDRpcIIx/V2TXgsP3OYbfWsoWTeTJy8qDw0LiYQt4BQjePd8i9IeKajJF4i2g
         tYxNDqgo6t0bu9630XKDcNnpF4ElZtp2x2fgc5AtNTJFtRvy2oStzq15e0C5f1WJBSS1
         tY2lrB+QKR3NM+b228hQCkucdhy5ljef8dM0vTh1q8tzlK199ezO3RzuusBOvtLhPH6z
         7RhbgQY6h9Kc0TvNxHwJDxJzx2A2r5VK3OphVpY3tbg9WKl4rDAaFZeqJCUcHjmm8S7a
         u56Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id v24si6989951pff.191.2019.06.04.19.54.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Jun 2019 19:54:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of lkp@intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga005.jf.intel.com ([10.7.209.41])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 04 Jun 2019 19:54:01 -0700
X-ExtLoop1: 1
Received: from lkp-server01.sh.intel.com (HELO lkp-server01) ([10.239.97.150])
  by orsmga005.jf.intel.com with ESMTP; 04 Jun 2019 19:53:59 -0700
Received: from kbuild by lkp-server01 with local (Exim 4.89)
	(envelope-from <lkp@intel.com>)
	id 1hYM3q-000HLi-Ro; Wed, 05 Jun 2019 10:53:58 +0800
Date: Wed, 5 Jun 2019 10:53:28 +0800
From: kbuild test robot <lkp@intel.com>
To: Maninder Singh <maninder1.s@samsung.com>
Cc: kbuild-all@01.org, Roman Gushchin <guro@fb.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Vaneet Narang <v.narang@samsung.com>, Joe Perches <joe@perches.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Memory Management List <linux-mm@kvack.org>
Subject: [rgushchin:kmem_reparent.6 16/236] fs/btrfs/zstd.c:396:35: sparse:
 sparse: incorrect type in argument 1 (different base types)
Message-ID: <201906051026.KaU8WbVl%lkp@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
X-Patchwork-Hint: ignore
User-Agent: Mutt/1.5.23 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

tree:   https://github.com/rgushchin/linux.git kmem_reparent.6
head:   8bc1e83aac01a49736748e58f885dec56eda5db3
commit: 96d3001e2f61722b7e3d26456133ff2779de268b [16/236] zstd: pass pointer rathen than structure to functions
reproduce:
        # apt-get install sparse
        # sparse version: v0.6.1-rc1-7-g2b96cd8-dirty
        git checkout 96d3001e2f61722b7e3d26456133ff2779de268b
        make ARCH=x86_64 allmodconfig
        make C=1 CF='-fdiagnostic-prefix -D__CHECK_ENDIAN__'

If you fix the issue, kindly add following tag
Reported-by: kbuild test robot <lkp@intel.com>


sparse warnings: (new ones prefixed by >>)

>> fs/btrfs/zstd.c:396:35: sparse: sparse: incorrect type in argument 1 (different base types) @@    expected struct ZSTD_parameters const [usertype] *params @@    got ZSTD_parameters const [usertype] *params @@
>> fs/btrfs/zstd.c:396:35: sparse:    expected struct ZSTD_parameters const [usertype] *params
>> fs/btrfs/zstd.c:396:35: sparse:    got struct ZSTD_parameters [usertype] params

vim +396 fs/btrfs/zstd.c

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

