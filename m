Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 919FCC4321A
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 13:52:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 38C9120673
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 13:52:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="MrxNbxyw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 38C9120673
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 985976B0006; Tue, 11 Jun 2019 09:52:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 937056B0008; Tue, 11 Jun 2019 09:52:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7D6D66B000A; Tue, 11 Jun 2019 09:52:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 425886B0006
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 09:52:18 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id b127so9663505pfb.8
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 06:52:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=IWz7rmxRuciLtbVGhKXAvWnIWoY/90SUiu16s3M1vAk=;
        b=T0W/R+1oxud9bzrRbNB3Q31mQek0II0zWGVnjXgEv1I0/WFCSUlwLjSBvNmeOpkL2y
         +dlFh0hLl0HD1S3C3v7Lo43HP+xGKnknGRkLf2r6PnjcaJk8K4DzYJio8+wbsE4H+cjE
         HZslcPqgGyvXg9SemgyeoiAAxwLAXUuLqqCQLvWR0LIQDxttfHfELaTa97LLSOed/oVQ
         wIRN5mXXjmqMYNQClosE0gZOT+m9CAl6iZKVrEaXLJa7sGHtMFN0Falca4pE13f1hyYG
         iJJwGYXZ0nLKQKNRmaQQywETUWAZk+i+dL8f9vLOsSqSIEq8vJDDmnMUlX2gTT2L6ofw
         oL1w==
X-Gm-Message-State: APjAAAUxMSTeHfMS1xFIEK6k6ay4N6MJOo83j4koKaRzNtCmWVbjDOL3
	OPyeejd+m+97N8tfbEfAshoZUjHf9GkWS/Z4Fzk5vnroyGG1s2gzgXd5pZ822qbv/A4zxeY2Wou
	1E0U7jzIT/cZcEb4Q6kEtd8nndldjlzNfw1D7VuWdRQO0P/9foL+SLXmUGX4LVEzerg==
X-Received: by 2002:a62:b405:: with SMTP id h5mr78371188pfn.85.1560261137875;
        Tue, 11 Jun 2019 06:52:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzIl+aDazyMI+MgtJUVWvFhRnFpcRfTru0kJlDTXW614wtlmKC+JHBsF4kzE/JZN9DOZ7AU
X-Received: by 2002:a62:b405:: with SMTP id h5mr78371131pfn.85.1560261137017;
        Tue, 11 Jun 2019 06:52:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560261137; cv=none;
        d=google.com; s=arc-20160816;
        b=Qx/0SdSfY2E248aGuICtVwdvnkUywVyfQGPT0V7BvMFrryzpSRmP4MpRoY5K+m1rm+
         +0sg7AFzRWktNjTGt39nD81Q3H+Z6BkW3aV1817+EulHMYjxYoiUFt6abGjyuokoLLMa
         gbphvH4uJ+YsNGWQa34RF26DCOtjvIZguvFb6rIK7vlbvypVKBttrnjSNbTOfIIUE2kM
         8hsQQPhA0Wqq/YOBWM/DuhIsr5x59SOLGQB+3kIGYBeYOPa3ueGopglXNxL1ekCxj+8F
         tnnsLjccj3Podv6ai/gEntGEwsXMrYNx4uVaHp4CkMUvHqQChriVbhir1+R/+BVO9Qeg
         ocpA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=IWz7rmxRuciLtbVGhKXAvWnIWoY/90SUiu16s3M1vAk=;
        b=pZlYNMDM6axCpeldRNEE9WweOsgEeDfY+/8Fi6LQRJCCgUyfA3wQVd1FOl4ETCNL2x
         rtFaN6xCug7ZM21VCI6QPz0B0iqUajajL7+F6epFmUl5NKm+NclZKVUCbqCMOF3ahW/D
         nx53JffluAdk82XfchyruCtx6u8A1RjoiOyMSlq3AzQCkWpGslTUKXB2zF64IX4rP5Sl
         e+FKLOnwiNgtiyBmrr3HTuvMTZNSXRod04+uuBPAHmPC1+IqHY/slo/xuDpauNwkztuS
         kmZnd229+j7/W+4EI4ObsE9JOJUvLeCSL98Wkxo4U1cBmHQ7KT+gl7xqbtoyNv7D5sA2
         XOxw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=MrxNbxyw;
       spf=pass (google.com: best guess record for domain of batv+98d4ae9035936dc2f97b+5770+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+98d4ae9035936dc2f97b+5770+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id a69si13163086pla.178.2019.06.11.06.52.16
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 11 Jun 2019 06:52:17 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+98d4ae9035936dc2f97b+5770+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=MrxNbxyw;
       spf=pass (google.com: best guess record for domain of batv+98d4ae9035936dc2f97b+5770+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+98d4ae9035936dc2f97b+5770+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=IWz7rmxRuciLtbVGhKXAvWnIWoY/90SUiu16s3M1vAk=; b=MrxNbxywR2iqrcOnj6vuLsTEy
	tWldvXIf6cyAQENNln9VVSR4c4dc4mq9iq0ZiBlYqT+NEXj/xa2UBqMPcPTLee2+C1rZtOmresAMd
	9gGkT6gOur2Qc6RC+Oxa6POW7rdb4t5F07I3FrP1nk6PNjviQYoLtMO4pfbJnHjbndylgNxjBNurw
	AW8ZdUfhyZCpgV3/X7hjLOpVeYJql4oqa8e7bCRgEFkzPOA1gkLqJbkH4EBK9DX3TjF+x/y7s3Wq6
	UklaPdSaF7ZwsqIR9r/B9v1l2jotkzYTvPMQ9ns3I4dTNnupm+/2zKFMW5t3SNRyWF4o8pIOBGPYF
	lu39j1wOQ==;
Received: from hch by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hahC8-0003JG-TH; Tue, 11 Jun 2019 13:52:12 +0000
Date: Tue, 11 Jun 2019 06:52:12 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Pingfan Liu <kernelfans@gmail.com>
Cc: John Hubbard <jhubbard@nvidia.com>,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	Ira Weiny <ira.weiny@intel.com>, Mike Rapoport <rppt@linux.ibm.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Matthew Wilcox <willy@infradead.org>,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
	Keith Busch <keith.busch@intel.com>,
	Christoph Hellwig <hch@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>
Subject: Re: [PATCHv3 1/2] mm/gup: fix omission of check on FOLL_LONGTERM in
 get_user_pages_fast()
Message-ID: <20190611135212.GA4591@infradead.org>
References: <1559725820-26138-1-git-send-email-kernelfans@gmail.com>
 <20190605144912.f0059d4bd13c563ddb37877e@linux-foundation.org>
 <CAFgQCTur5ReVHm6NHdbD3wWM5WOiAzhfEXdLnBGRdZtf7q1HFw@mail.gmail.com>
 <2b0a65ec-4fb0-430e-3e6a-b713fb5bb28f@nvidia.com>
 <CAFgQCTtS7qOByXBnGzCW-Rm9fiNsVmhQTgqmNU920m77XyAwZQ@mail.gmail.com>
 <20190611122935.GA9919@dhcp-128-55.nay.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190611122935.GA9919@dhcp-128-55.nay.redhat.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 11, 2019 at 08:29:35PM +0800, Pingfan Liu wrote:
> Unable to get a NVME device to have a test. And when testing fio on the

How would a nvme test help?  FOLL_LONGTERM isn't used by any performance
critical path to start with, so I don't see how this patch could be
a problem.

