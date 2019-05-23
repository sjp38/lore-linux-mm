Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3B264C282E1
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 18:22:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 008F42184B
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 18:22:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Wde0ZWPb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 008F42184B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8EE8F6B029A; Thu, 23 May 2019 14:22:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8A0416B029C; Thu, 23 May 2019 14:22:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7B5096B029D; Thu, 23 May 2019 14:22:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 47F8F6B029A
	for <linux-mm@kvack.org>; Thu, 23 May 2019 14:22:13 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id d36so3412056pla.18
        for <linux-mm@kvack.org>; Thu, 23 May 2019 11:22:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=P7P/rAyxWzeNmj+2ZKGl+tpZq+0DY4fZmz/12N/pJuk=;
        b=Ws6kn8JeQ9N8CBsVgw0tXJ974rlXh8sb7qHJgqIGGWSk844qnMIDE0wmgHkV06Sbz8
         vSb8hW9AOcJZCKaVwUJzr1RdCsIMpYPrmEsyaBuM5JdgASqqEVaV2Ss0vsEyY+XxKvt1
         89bg05ZlzMpghZVNJGqFEFbthsVCksrsJlUPJW5BUusP9vlKPsK9LPaXfJJqdRHr7p/U
         2IDwQ1kKtLn5hmQUJknhhVE1ZuU6G39DwODiwXIWqt/Q1SAeJQqIAxT3SYuDYcA7f+8o
         bkQijFmnSaXRCieziabn/P+hWiXq1E6NznXtBSQLuvKWdoR0zV/uNAjAqa2EhOpIRjBt
         OalA==
X-Gm-Message-State: APjAAAX6EDEr2nnptsDUIctifoyScCDsaCEm8cDnI6LOHueibT5jFyTf
	+L2wd0eap4vym5vEpe+FEZOzpFPj7leIg4ydZm+uf1m9i7lbpsNZO2qzdSA14u9fdEHAigZU35E
	bN/Yc4yzkTCNwyDPBr6RdBIhvR0x4mV7usW3QfaSKCuPu4a90Fp57Pxt8VGzDGdgSYA==
X-Received: by 2002:a63:78cf:: with SMTP id t198mr10986762pgc.82.1558635732868;
        Thu, 23 May 2019 11:22:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzRho7Hmvf+pwnqsO0XH+cb6DhHKZAwSvxJncQK+hGJl+BhVDb7nXrpYaLmJ9w5fxadJnZz
X-Received: by 2002:a63:78cf:: with SMTP id t198mr10986639pgc.82.1558635731805;
        Thu, 23 May 2019 11:22:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558635731; cv=none;
        d=google.com; s=arc-20160816;
        b=JmGn5cZ0B6xFl6bFjne8dOgoT85gNmBDxr29cV8t41qbqCkeqdv14ropkSaHXfZ0lk
         Rggw7+1x9OP72je5WQgIEUXq14UM4eoRYLopi/+sTOMOfKo7JjQwzyrY2ychrgez6Jg8
         vVHGwtEQ2gfeOF/EOjOsXjiYAG9dUvMTPHVNj9JYLab8Zcr8dKlk504tDruqhXzM1FfW
         t17n2DVSI6ho76Tx1HYf+bTUqK7WcXc03oRE7B9rKbCecoCiVWP09pBjp2z9N3mw3UEb
         Z+piDl41qKTJEWpfPQQJ1ytp7sPac03yNWGcNuq3oYMHKnryGB6T5zIOnmGcpHEhaikV
         SRfw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=P7P/rAyxWzeNmj+2ZKGl+tpZq+0DY4fZmz/12N/pJuk=;
        b=ZIuHe+LPabMf1RnYOHaLSs3KhpXQ2MkZcuH6tfZDjejIdYY0Q1B2jYR6pMsM+whg4I
         D+oHUhlELBnSHKy0O269gvMR49kTLtVA6sWDl+KyTqWVc2UB4qBLvZj0ZsqHZEqJfYlp
         sGvp7Fw50YjAqdUDfj/ZprFRueHKUdUjl18jNhLzEnmpcksc1hKrXcP1eCkGutc8CJCP
         MkS/9f5nhRl/PI0qVKayH6T74uN+C2T9uv9X1g/pCpXg5LkOl0Q5QxV3mnEAXoAppn7c
         DSA5uqE4lliiQj8eICCDZ0FrU6Wjuli4rvVAaqzJlLvidiNC60GhI0ALrcSQu+d8cGbx
         YDag==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Wde0ZWPb;
       spf=pass (google.com: best guess record for domain of batv+c417bddcefb42f015981+5751+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+c417bddcefb42f015981+5751+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id o189si84676pfg.216.2019.05.23.11.22.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 23 May 2019 11:22:09 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+c417bddcefb42f015981+5751+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Wde0ZWPb;
       spf=pass (google.com: best guess record for domain of batv+c417bddcefb42f015981+5751+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+c417bddcefb42f015981+5751+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=P7P/rAyxWzeNmj+2ZKGl+tpZq+0DY4fZmz/12N/pJuk=; b=Wde0ZWPb9FtpJuaCuRkz+Oj3t
	9+p0YOonkXuC3u4X4AXtUT4KAfKnvE66numdW8tyfdFbduc2ElXlKRxIurPWDwSh7i5AVnGVlPpc5
	f9J3YjyaP+W0O+TknVeRWVKRGZhqK6NbjwwVod4BoU9oTH3OMxlWykszXqakoQBr60cazHGnd4jzU
	QqySE8XnnyGdfQouYCCmHv6NNVUKCFDMhAPx4ES9kMnEdqlQe7/swTbiGEQj2hVjJaYyHli5FQjFo
	sm4npVWE/AP2zOFAdUrimgK4LVpwiqZ28dJpiDdxN9phrgJk+UMq03iqculdG/lWQTgdhBRPUE00H
	0suuDmC9Q==;
Received: from hch by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hTsLv-0000zv-LU; Thu, 23 May 2019 18:22:07 +0000
Date: Thu, 23 May 2019 11:22:07 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: linux-rdma@vger.kernel.org, linux-mm@kvack.org,
	Jerome Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>,
	Jason Gunthorpe <jgg@mellanox.com>
Subject: Re: [RFC PATCH 02/11] mm/hmm: Use hmm_mirror not mm as an argument
 for hmm_register_range
Message-ID: <20190523182207.GA3816@infradead.org>
References: <20190523153436.19102-1-jgg@ziepe.ca>
 <20190523153436.19102-3-jgg@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190523153436.19102-3-jgg@ziepe.ca>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Nitpick:

s/hmm_register_range/hmm_range_register/ in the subject and patch
description.

