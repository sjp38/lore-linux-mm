Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6BBB8C4360F
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 23:38:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0A03E2192D
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 23:38:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0A03E2192D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 51DFE8E0002; Fri, 15 Feb 2019 18:38:37 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4A4638E0001; Fri, 15 Feb 2019 18:38:37 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 31EE98E0002; Fri, 15 Feb 2019 18:38:37 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id E44C78E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 18:38:36 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id k10so8736283pfi.5
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 15:38:36 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=PgbJKjz1ElLhJIP8z8I+SOBlpvAz3jK66ifXTPLSCx0=;
        b=r4jKZSU3TElLrg1z/eAoe7o0W9lFqXGc6YwFGFAlarHhZ7ff1ZgCINDFAb/gQ3pme1
         PQrW5GnCHzAx2bFfoUEz6xTvuODXglTv5aclEZD2B8fUXQbV9j0rOefzrnuG7BVWny8z
         vXQqDU2+fGV19zS8GUB+RJ3l1XOGQSr/LV4WQA/fISbSgyTiHEJRPPj0D62GdmFrUvU5
         7ae5l+kwybz2T6XrH9be0Vj6YiIvrdNYxSurGUkgXG0xdi71KdyJK8xPxI/b591IImMU
         XvtQhrlDO8VLgST/YwqPuAyFbqtjrHF6I+DdbxYzlDUVfGIojoJjYj19Z1HlUxJ+lFRV
         8JuA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAubLFFlwnP69XiWDv+xiyEUC+1QRdBDcMJ637yHmB4ctA5uZIk8K
	Pf8VNZLd4Vlhy4z30XQny820uQiDuNzzSZ2NQtpmiSfLpSePji2T1v9b22KiyQ2Ef1Lxnhjsdxr
	P7m9PR8QLf955iQWpUOouDgv/4CluwpVGrrkRsxKjb482fnvnk/Llx1r3OcIkxU7eeg==
X-Received: by 2002:a17:902:8d94:: with SMTP id v20mr12727400plo.194.1550273916483;
        Fri, 15 Feb 2019 15:38:36 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia1PliHhdYTgJf0T5zunz0Vd1CucUMA1bTuTShp3uDysxyzQhHLprltGh/RZ9FOX6WaS1CJ
X-Received: by 2002:a17:902:8d94:: with SMTP id v20mr12727359plo.194.1550273915669;
        Fri, 15 Feb 2019 15:38:35 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550273915; cv=none;
        d=google.com; s=arc-20160816;
        b=V2SB0jHvKumO2jkOj2JixRi6OGBwaUzcA9LdCj9+vKc24FHfyfBdPIkquaNdZ2DEZ+
         f8sK4djFzTV3yyH3/r4uKy9RO4uwCi5SVn6hIS9Za0/qsBtsjN6TmjxpYi7mHN0v7GMX
         4qfwW69UX2nj8TULpzmAPBpTWCOEk+8zwxQ1mGHF2zoUqv7PHT/qmpJa22mxFgH+HC+w
         kh3iKiruuozaYL1E13AzKawnoKHJhy6ASVg7LDh3WBnSyoN+zsEoK7rAXCYjGzs/7p0w
         hrSmu0Gsygp0e/S5dXgrm3mcQ5q4TilaIY0VbAnYhojqLxSrjwCSVobPEAtAUpFoPwyQ
         x4vw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=PgbJKjz1ElLhJIP8z8I+SOBlpvAz3jK66ifXTPLSCx0=;
        b=pLnVuYsd+/7Twm8LK14zrGLXr7deU8xgT/CJP1sXeJvJeiwae596ppynuOakxVKBMJ
         xHYHo4xsrJYvFvokUnpULSbk0uRqLLyqAw6+5nHPd5DCWpHOjL1PVuOfN2hJM0958FW7
         wDTLadNP0Sk/oBxuz6C9mKWiLrcRAMD6F0lQmrMasCOIaudmw7i0WCNEvj598/RjWSeN
         lkve9DwwEA3Z1MdZjZ7es+tSi/co+sLdh52oP25LGNw4K3Zc1N0cFOnUf/xXlDLl6N1D
         cduwTGpR/11HHJ9FvpUJ79KtK6nSX82qvenBltRnWWjRIeOy9gdIvfrb6Wim/5juP53k
         Yz1w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id k11si6760210pgg.430.2019.02.15.15.38.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 15:38:35 -0800 (PST)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) client-ip=134.134.136.24;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by orsmga102.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 15 Feb 2019 15:38:35 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,374,1544515200"; 
   d="scan'208";a="134717010"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga002.jf.intel.com with ESMTP; 15 Feb 2019 15:38:34 -0800
Date: Fri, 15 Feb 2019 15:38:29 -0800
From: Ira Weiny <ira.weiny@intel.com>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Christopher Lameter <cl@linux.com>,
	Matthew Wilcox <willy@infradead.org>,
	Dave Chinner <david@fromorbit.com>,
	Jerome Glisse <jglisse@redhat.com>,
	Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>,
	Doug Ledford <dledford@redhat.com>,
	lsf-pc@lists.linux-foundation.org,
	linux-rdma <linux-rdma@vger.kernel.org>,
	Linux MM <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	John Hubbard <jhubbard@nvidia.com>,
	Michal Hocko <mhocko@kernel.org>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving
 longterm-GUP usage by RDMA
Message-ID: <20190215233828.GB30818@iweiny-DESK2.sc.intel.com>
References: <CAPcyv4iHso+PqAm-4NfF0svoK4mELJMSWNp+vsG43UaW1S2eew@mail.gmail.com>
 <20190211180654.GB24692@ziepe.ca>
 <20190214202622.GB3420@redhat.com>
 <20190214205049.GC12668@bombadil.infradead.org>
 <20190214213922.GD3420@redhat.com>
 <20190215011921.GS20493@dastard>
 <01000168f1d25e3a-2857236c-a7cc-44b8-a5f3-f51c2cfe6ce4-000000@email.amazonses.com>
 <20190215180852.GJ12668@bombadil.infradead.org>
 <01000168f26d9e0c-aef3255a-5059-4657-b241-dae66663bbea-000000@email.amazonses.com>
 <20190215220031.GB8001@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190215220031.GB8001@ziepe.ca>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 15, 2019 at 03:00:31PM -0700, Jason Gunthorpe wrote:
> On Fri, Feb 15, 2019 at 06:31:36PM +0000, Christopher Lameter wrote:
> > On Fri, 15 Feb 2019, Matthew Wilcox wrote:
> > 
> > > > Since RDMA is something similar: Can we say that a file that is used for
> > > > RDMA should not use the page cache?
> > >
> > > That makes no sense.  The page cache is the standard synchronisation point
> > > for filesystems and processes.  The only problems come in for the things
> > > which bypass the page cache like O_DIRECT and DAX.
> > 
> > It makes a lot of sense since the filesystems play COW etc games with the
> > pages and RDMA is very much like O_DIRECT in that the pages are modified
> > directly under I/O. It also bypasses the page cache in case you have
> > not noticed yet.
> 
> It is quite different, O_DIRECT modifies the physical blocks on the
> storage, bypassing the memory copy.
>

Really?  I thought O_DIRECT allowed the block drivers to write to/from user
space buffers.  But the _storage_ was still under the control of the block
drivers?

>
> RDMA modifies the memory copy.
> 
> pages are necessary to do RDMA, and those pages have to be flushed to
> disk.. So I'm not seeing how it can be disconnected from the page
> cache?

I don't disagree with this.

Ira

> 
> Jason

