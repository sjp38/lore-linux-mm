Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4B251C169C4
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 20:50:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 03B08217F9
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 20:50:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="kjMhfcP6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 03B08217F9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A987C8E00F3; Wed,  6 Feb 2019 15:49:59 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A48858E00CE; Wed,  6 Feb 2019 15:49:59 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 937E78E00F3; Wed,  6 Feb 2019 15:49:59 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 529868E00CE
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 15:49:59 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id m16so5486845pgd.0
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 12:49:59 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=NL1MPyRU/T/2aVS0UzGM98TCSfb5ympBh3xbI7SJ34A=;
        b=BDSEu3Kl1O1b75Bag7oHEiffZygbjcyKrfPDIoiWXXZvjhqDGcSYKtYwD9TbI8X1r8
         itFmN4yt4gl7jrWoythzRgBvz0Ce6AJgIKV9SKjTZU2GrGIG+w9j62eAPQ/BrgwXsIX3
         Jt/4dQAzY1WMH9yqGo8L8AqM8DNI2I8CD81s6vz7Rpw+Fbh23mjD0U+1/trh7YmE4+pb
         uTMyaX6mvgk6h2bgVSvj7E5Xdx/ClPvJ9mUXX+cROrD8Dnz2ufxyyD9CfrR5yoK5biKf
         Zbs58htEZydKdpam4NO5AMVOJHH/SyuAOtBV+32mVi5acEjfUDCa4Tmo4/ku8goIRVnJ
         9z0g==
X-Gm-Message-State: AHQUAuaNNeQg4d5Xt87Vh1exChCnlED2ewrrnbziMd0CqSNiVEthRwcZ
	xHcJ4SSzm/yOW7vHaDmiDVLYHnRo1TlJwv6UPQ4hj1heK1rgdWaGvsxWVWxtcXaGWqT+4KOUuvD
	BDI3LADWfnpTkrYkJA54HqCmJn0LJJ8Vr9/+spmSAoGEyPFMUhOQe7Po4gpuOI4tNXw==
X-Received: by 2002:a17:902:ec06:: with SMTP id cy6mr12363185plb.11.1549486199018;
        Wed, 06 Feb 2019 12:49:59 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZQDw/WZ1knH457iZX2zmznEMvCBNVoNY+MaQhCu5aPr7y+kraXG0HHv5HFwC9xfApRb3qL
X-Received: by 2002:a17:902:ec06:: with SMTP id cy6mr12363143plb.11.1549486198407;
        Wed, 06 Feb 2019 12:49:58 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549486198; cv=none;
        d=google.com; s=arc-20160816;
        b=N0mHPd13x55nN3wnizY6UXjmGz8ESKvCFlmZO8kjviO5KdB+Ucdwerbot9kfIuj3XX
         qH9QIMavarNDiO1VGL/aWGyEd14AS2gTBEMVwIgGoflDB+MaTTsXHQ/qvhV+CI23blhY
         K6ABN5VB/Dmh6Wx2jx3yYH96X5fMB3TKRIynAkWOGUUCzENlKJtxaYEyyQAAtB8SjiE+
         T95IvuSPC4Ky7H98x/dmj8VHyeodO/Fnqia1sg1++cwc1BRB6uLprrSg6/GF4uS04lAV
         OyRR6gaxocRxlC5AdwX9Mj83jZxumpAGykHvx85wZ4Yh0XWBmKsAyvxhNRLpk6FetmOQ
         1ujw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=NL1MPyRU/T/2aVS0UzGM98TCSfb5ympBh3xbI7SJ34A=;
        b=MPvwbX2E9C1E0gszi3F0brp3GEki0oIKnfgXZrNAx4/t2NoC24fIFYoAhrWN/l189Y
         wYTbl6XwXLQdbuVn6zz8Hd3EaV1z7hzaRF2tBoAZtMFAg+9dvQBVhRpA0o2+xjJjlDUU
         mgL+JU0NoySkY36lymJgGmYtgp1RbbmsJQfj9b5KZOmYDh3SblzEnAXgvra4hKbPqPi+
         CN4rlbhAEGIBkAD+6eSO8fwTbLcizUJAQwnYQcv16WF3N8h+3KLRVwcii/hQSgzREqc6
         t9gJKrOnoFoccyml7tmeoe6zpjYVBC3I0wFWI9HSuIjQeBdR1ze+Jpe/Sdjm0nB54kS6
         IJNw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=kjMhfcP6;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id bd12si6070397plb.193.2019.02.06.12.49.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 06 Feb 2019 12:49:58 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=kjMhfcP6;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=NL1MPyRU/T/2aVS0UzGM98TCSfb5ympBh3xbI7SJ34A=; b=kjMhfcP6/nCSoSlWl2K7h4tCU
	K2r5F+WrqeCQDKBF4VVmFZdO5boPVHwGwaWTO2Bqp+nKvEdq+ZNoBMPuAPs3rrnRSHvcydo8c60Ee
	Zc9rJaOiEUGEz4+y+qKlnkVU2rVOeswtzmffDldixXaGdoqxclVsWsSKObzWa5v01UXR3hxh0LUjc
	lCjORh510SMfx5CEDfyN7x2k73Ylio2FCe9iICPDP/kCOxygcV2Ds0wGEiqOZqKtEGrfgeZhRn9Fi
	s5wTUFJfgRKHPyRNWHeQS55tsIsDEtFBuKPFb6OSatbKMpWxK+FAv7MO95tcPWJ6Wmc/1xKhMsHgH
	qv1E47GOQ==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1grU8o-0001SI-TO; Wed, 06 Feb 2019 20:49:54 +0000
Date: Wed, 6 Feb 2019 12:49:54 -0800
From: Matthew Wilcox <willy@infradead.org>
To: Doug Ledford <dledford@redhat.com>
Cc: Christopher Lameter <cl@linux.com>, Jason Gunthorpe <jgg@ziepe.ca>,
	Jan Kara <jack@suse.cz>, Ira Weiny <ira.weiny@intel.com>,
	lsf-pc@lists.linux-foundation.org, linux-rdma@vger.kernel.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	John Hubbard <jhubbard@nvidia.com>,
	Jerome Glisse <jglisse@redhat.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>,
	Michal Hocko <mhocko@kernel.org>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving
 longterm-GUP usage by RDMA
Message-ID: <20190206204954.GS21860@bombadil.infradead.org>
References: <20190206173114.GB12227@ziepe.ca>
 <20190206175233.GN21860@bombadil.infradead.org>
 <47820c4d696aee41225854071ec73373a273fd4a.camel@redhat.com>
 <01000168c43d594c-7979fcf8-b9c1-4bda-b29a-500efe001d66-000000@email.amazonses.com>
 <20190206194055.GP21860@bombadil.infradead.org>
 <a9df9be75966f34f55f843a3cd7e1ee7d497c7fa.camel@redhat.com>
 <20190206202021.GQ21860@bombadil.infradead.org>
 <a8dc27e81182060b3480127332c77ac624abcb22.camel@redhat.com>
 <20190206204128.GR21860@bombadil.infradead.org>
 <fbdeccb01f7d0ba2f6ebb69660b7aa3d99690042.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <fbdeccb01f7d0ba2f6ebb69660b7aa3d99690042.camel@redhat.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 06, 2019 at 03:47:53PM -0500, Doug Ledford wrote:
> On Wed, 2019-02-06 at 12:41 -0800, Matthew Wilcox wrote:
> > On Wed, Feb 06, 2019 at 03:28:35PM -0500, Doug Ledford wrote:
> > > On Wed, 2019-02-06 at 12:20 -0800, Matthew Wilcox wrote:
> > > > Not hot-unplugging the RDMA device but hot-unplugging an NV-DIMM.

^^^ I think you missed this line ^^^

> You said "now that I think about it, there was a desire to support hot-
> unplug which also needed revoke".  For us, hot unplug is done at the
> device level and means all connections must be torn down.  So in the
> context of this argument, if people want revoke so DAX can migrate from
> one NV-DIMM to another, ok.  But revoke does not help RDMA migrate.
> 
> If, instead, you mean that you want to support hot unplug of an NV-DIMM
> that is currently the target of RDMA transfers, then I believe
> Christoph's answer on this is correct.  It all boils down to which
> device you are talking about doing the hot unplug on.

