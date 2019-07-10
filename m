Return-Path: <SRS0=tO+N=VH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 616FBC74A36
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 17:44:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 04FF12087F
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 17:44:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="axQtLVlx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 04FF12087F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 70C208E007F; Wed, 10 Jul 2019 13:44:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6BCBF8E0032; Wed, 10 Jul 2019 13:44:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 584048E007F; Wed, 10 Jul 2019 13:44:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 26AFD8E0032
	for <linux-mm@kvack.org>; Wed, 10 Jul 2019 13:44:30 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id y66so1741230pfb.21
        for <linux-mm@kvack.org>; Wed, 10 Jul 2019 10:44:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=iWMY9Ra6fhg6EXLcSiaO3PQbn2oiv74r4PYLZuZM2BU=;
        b=SiL7LupAPlMYvlQLkA1lGOruu5lA36rlSRQ6OvVsWP24rQ9UQCEMBYXsYk8Ajwj87c
         alJv1V8EqqADTorBoxtaXiFPqncgypNy6SxfZV0X7MOT+Cnlz//Gb5ElKOvVOCO4fVRs
         /aCiH9vCy1AHzOw6lJXK3JJivhvZWHdRXvorzNvRm0pPbzkB3OIFLnaeowuBdADifAxk
         DAww9KZ6oZx1/3eX9DPRJBY6tmgTcDCULdbLGFgMtX6HFD6rntUeB+v4/CRapaP3Zs7B
         BfcB0OoKBTLf/pUb/NvyNlrvLZBxE9VdFD/Bh4XRGXVHFIf3lOq8qPOjB6CHW90kaCuW
         eeow==
X-Gm-Message-State: APjAAAVZjb1V15HcmYt4eYWuide4YdGsjcAFtQ9glG7dO4A/Qycn1fPN
	1lMgWr1iW/C306ss01sS+uMuUZHLJMGa5qNxRFYlXP9R8ven+mCiQV3xDq0ca10chF1YwgkAkAV
	CtyfnkkQrYV1nq67vHVtGzrfsno4ditvz5Dm/4kv8mQr+D4UHb4jHsyEu8iMFE9ySHQ==
X-Received: by 2002:a17:90a:ab0b:: with SMTP id m11mr8591424pjq.73.1562780669701;
        Wed, 10 Jul 2019 10:44:29 -0700 (PDT)
X-Received: by 2002:a17:90a:ab0b:: with SMTP id m11mr8591364pjq.73.1562780668749;
        Wed, 10 Jul 2019 10:44:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562780668; cv=none;
        d=google.com; s=arc-20160816;
        b=vcuP6G+jbuGpieHihrbJZWc6qaXylbKwVGYQ0D09BdP4AKhBsHbYrd6WFzJ3Z/1Xn6
         rdLmbyPXFQb8+IBdLkYgK+5DdRJ1SC0g3YUC7VBjMVnvze20+Z7stlgr/2PYe5pJQehr
         HPHOwTQ2r/u75EkcgPHlCSBnhpXTk474KyOm/rEsnJNgwW+W/G7DgCf2ZYoGsSSdTNPy
         xVFAj/plaBxtKZLyKxTKkMn71OtO/wJHv5Wumplp9+QO5nnB8JVb21OxTGds8uC/cSCp
         O8BzYm967YIZvdAVHQMLnu6u/n3cF6CNxc3aZcCgA470cNNNdih5Af4/ccxWvr+bsiZt
         6IHQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=iWMY9Ra6fhg6EXLcSiaO3PQbn2oiv74r4PYLZuZM2BU=;
        b=bfWC/jWl7uWr8o+gOZGovtEpQFXEmJNxGvQ82gY2c1ubftxT0Ajim01EaCV3b5m+Rm
         8tPjSO73Jff8GvoDrSxy332xTi/PTWOJ2QkFSt9qoGoc12Io3Ph8U0UWoxGODyTY/djt
         C85ThBaf19Kp8ftt24GdBwhWtXgTLackU+0CNkcsSdkxfUEm0HyEwCv4E8Nmn/X5SDmn
         EWQUWf2OF0mPazmnD9SQh52WxS22h4nJmqk9Ur9uSD7hA2Bh9Mp6rmgFo95gxauvbZFx
         UmmEFL1CEmVf1BdQwNkp+d8ugvy84Y8/HH/iYulwfCa5KIFNAagAWkCKgsq2nEGLoaIw
         ovVw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=axQtLVlx;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s19sor1557539pgi.13.2019.07.10.10.44.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Jul 2019 10:44:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=axQtLVlx;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=iWMY9Ra6fhg6EXLcSiaO3PQbn2oiv74r4PYLZuZM2BU=;
        b=axQtLVlxBbG2rukB4uIEh3aDgpy4FVcpO0GP/piahI3Obgr+rZibgLCVElkJiFLY7w
         3JeU1pgGcUvAjJcRn1s0c75htzs2+FGj/9N0jRvMyrTOIrRKuoNx+MB+l7IkG8G+s71L
         89cqtxOCVpM5EfPFLvBjibAvHWJvgCpc2nVLRUGbBX0UKtG1lxR7l/ToMmPkdPDSn7So
         fZ9asLA/swzK89Ng61WiyMSN19TnEfEsP0wWxWd6vVTYQ59wz7HTFto7++v2UlC/wnZt
         XCH/XEdhlxPfFZJ0WwkBRJ1tgzdA8vKk19ExiwlatWdYZVOo1JH5BsmesMvm1aWejERz
         pSig==
X-Google-Smtp-Source: APXvYqzEHvJg5Hy2iDWq+GUuLPTBgqSstjUxb2RpWlYFGd98AAweC/ipWaTWFhYqPANU2G6KTh+dcQ==
X-Received: by 2002:a63:2606:: with SMTP id m6mr38342826pgm.436.1562780663359;
        Wed, 10 Jul 2019 10:44:23 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::2:5b9d])
        by smtp.gmail.com with ESMTPSA id l189sm2874023pfl.7.2019.07.10.10.44.21
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 10 Jul 2019 10:44:22 -0700 (PDT)
Date: Wed, 10 Jul 2019 13:44:18 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Song Liu <songliubraving@fb.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org, matthew.wilcox@oracle.com,
	kirill.shutemov@linux.intel.com, kernel-team@fb.com,
	william.kucharski@oracle.com, akpm@linux-foundation.org,
	hdanton@sina.com
Subject: Re: [PATCH v9 1/6] filemap: check compound_head(page)->mapping in
 filemap_fault()
Message-ID: <20190710174418.GA11197@cmpxchg.org>
References: <20190625001246.685563-1-songliubraving@fb.com>
 <20190625001246.685563-2-songliubraving@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190625001246.685563-2-songliubraving@fb.com>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 24, 2019 at 05:12:41PM -0700, Song Liu wrote:
> Currently, filemap_fault() avoids trace condition with truncate by

                                   -t

> checking page->mapping == mapping. This does not work for compound
> pages. This patch let it check compound_head(page)->mapping instead.
>
> Acked-by: Rik van Riel <riel@surriel.com>
> Signed-off-by: Song Liu <songliubraving@fb.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

