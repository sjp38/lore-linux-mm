Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 71698C04AB5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 06:18:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3351420874
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 06:18:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="hh3vfV36"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3351420874
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C1D816B026D; Thu,  6 Jun 2019 02:18:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BCE806B026F; Thu,  6 Jun 2019 02:18:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A96066B0270; Thu,  6 Jun 2019 02:18:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 705EA6B026D
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 02:18:32 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id l4so1133598pff.5
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 23:18:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=U8rF1uP19dnET207DcY9H/fsoaYvyqbT8DVHn5K5oRM=;
        b=gCrVj59Unva3Bny85FGG2o9d+oerNUYJ+KNvyZvmGr/vl/rxbqozaOhI0hmA6Q0pnw
         D6UViLpUR5qVQOZhDmUy6z/uAsKRZzVyZAcLUAvqvgfT4yM5PMsdqGFKCH9BKvj61bLU
         mj2wk8UWYe6mAuXZ5QaPJ9YYYw/dNVytund2koNrXzF2IR+MjWv7wmiXpoTe3mIMtRNm
         TE+PRrizSp+b8Qd2T8lGDgLIzcvWLUrDLQ9CnfMXZ3oF9O7NW6GtegOniRCol2q6S8Rr
         xmMhO/49aj/rtwYNhVFQtMGAgzmvJv673mys78B12WPVYTsARUmHv+JK7uGKK/W14DdA
         56Rw==
X-Gm-Message-State: APjAAAU+Ea3OY9xikfgrBOtJ5uWDaKueYVd6DeguJe9O+2aPW14XhzLm
	zzOkmmA9rU+li1OR4f3GomwR5Dz+3dR2l8jiecleBbfVAj20x7xHPWxGbzC9uLoMUTcKQQpUrsW
	Ye6eTtbOtTVgQ9icjnTAByqSz4cAAE3f7LaHcx51KYMeQGl8Nru7oxOp8nafZScpqIA==
X-Received: by 2002:a62:6145:: with SMTP id v66mr51061194pfb.144.1559801912010;
        Wed, 05 Jun 2019 23:18:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwFKbeTTkfKedtnDKHM96wo9+jFNnxnclj/BBPY7N59R8UIvjBNJ2Z6eGbDZ7ISB2SDII9W
X-Received: by 2002:a62:6145:: with SMTP id v66mr51061158pfb.144.1559801911406;
        Wed, 05 Jun 2019 23:18:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559801911; cv=none;
        d=google.com; s=arc-20160816;
        b=h7QawASkQL2n4sYBH9vzPR062QnURfaLOFVmmivahySan4i8Ugl7oY3fuFlXtfMd8J
         mPbum/gA+xro4yRMbuGsN9eLyZ+U74KxVS0rHaVkf2o05d4XBI4OV6EIcb7c5P0ZJgsF
         UF7Zonv1vwjOZQ5hZ/BUzpjTHmo7YqCRlgNuQAcMHep76GEvnXmzsh3a7IFPT5tBI6/M
         nPl4KDvQskxXrlmTa4qRy+gpZtW7NxYvhL5KqTiitzUApSA7fTDsFGGNGtkkKQQFtGPn
         ewj8cz3F1pGTpu3smviDCAgggxUrIUXyx+W+d0CZwRMoDKt7A6LVnqOH+J88Bsuk/qff
         FPrw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=U8rF1uP19dnET207DcY9H/fsoaYvyqbT8DVHn5K5oRM=;
        b=vur1rBTH8FyNEt2s9Cj2nY+96DSJHIaw9lIrUuFJzfAl0W5n2kvvPd596Rp8EHP+F3
         fkO4sdrQ9riXv8o0o7QxHivB8AHFyUpeFv3jN3Fk4cQZHDUclN+dsFATClprqRAsxdr0
         9IPVLZNlCDh3SpLO0aaXaWAdEXmWGYEtXpBwwAqi4XA4ydBCS3mxC4Renq5tTDwaCoTD
         dAZu9H+IQbazfXshmdXQcW1MKuyDQW+Hhr4G8HIYDoIvu4H/xgToNCMqW3DRIECtz1wm
         ZYo9NUf3xHA+4SFaxsTKaau4WFK+H1uup4hT3rMSyaxlMCd5+UcCFH3WfrA0l7YSZT26
         Gbuw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=hh3vfV36;
       spf=pass (google.com: best guess record for domain of batv+2a9871a3a082cf6dc382+5765+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+2a9871a3a082cf6dc382+5765+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id c8si992462pfn.208.2019.06.05.23.18.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 05 Jun 2019 23:18:31 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+2a9871a3a082cf6dc382+5765+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=hh3vfV36;
       spf=pass (google.com: best guess record for domain of batv+2a9871a3a082cf6dc382+5765+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+2a9871a3a082cf6dc382+5765+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=U8rF1uP19dnET207DcY9H/fsoaYvyqbT8DVHn5K5oRM=; b=hh3vfV36YrLiF3AZvb2T4/Qsm
	ZGpgeScpxKnNf0aS2baD3ki47trw/uHctB3wKBpv6V6SbCMpk2PfbKUk/5XgM8HNDjclepJ9Zdbz6
	2GcqhtFfRtwgOlRsLz0gTHbH/QD8c0RD1Nwv73lkSzrx4ZW4CsWVtPnTSaYKb7q2DM4NJWtdmuwyk
	Ib935aW8MHP3OauCGnonYIxkH5L3VSyJFRXG0U2YAfTuXHF11OiwL/C6RfAmS9J4JPPN67De362rW
	nJke29YpqUQ+h0Q/HmV6zGVwwZQCpJPnOD1sInPHpqtie3EXgVS+P5THX1FahoL367+4HTT4+qz1H
	qcJ4t2xpQ==;
Received: from hch by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hYljA-0005QG-0s; Thu, 06 Jun 2019 06:18:20 +0000
Date: Wed, 5 Jun 2019 23:18:19 -0700
From: Christoph Hellwig <hch@infradead.org>
To: ira.weiny@intel.com
Cc: Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>,
	Theodore Ts'o <tytso@mit.edu>, Jeff Layton <jlayton@kernel.org>,
	Dave Chinner <david@fromorbit.com>,
	Matthew Wilcox <willy@infradead.org>, linux-xfs@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	John Hubbard <jhubbard@nvidia.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-nvdimm@lists.01.org, linux-ext4@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH RFC 03/10] mm/gup: Pass flags down to __gup_device_huge*
 calls
Message-ID: <20190606061819.GA20520@infradead.org>
References: <20190606014544.8339-1-ira.weiny@intel.com>
 <20190606014544.8339-4-ira.weiny@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190606014544.8339-4-ira.weiny@intel.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 05, 2019 at 06:45:36PM -0700, ira.weiny@intel.com wrote:
> From: Ira Weiny <ira.weiny@intel.com>
> 
> In order to support checking for a layout lease on a FS DAX inode these
> calls need to know if FOLL_LONGTERM was specified.
> 
> Prepare for this with this patch.

The GUP fast argument passing is a mess.  That is why I've come up
with this as part of the (not ready) get_user_pages_fast_bvec
implementation:

http://git.infradead.org/users/hch/misc.git/commitdiff/c3d019802dbde5a4cc4160e7ec8ccba479b19f97

