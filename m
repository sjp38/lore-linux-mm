Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 09C88C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 15:28:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ADA6C20B7C
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 15:28:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="tHlQpyqz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ADA6C20B7C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 564106B0006; Thu, 13 Jun 2019 11:28:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 513C96B0008; Thu, 13 Jun 2019 11:28:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3DB5B6B000C; Thu, 13 Jun 2019 11:28:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0784C6B0006
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 11:28:02 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id h15so3807197pfn.3
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 08:28:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=vn04L/39CxGmnFvWZbLFG3AukuBPlzgMR3HJ4g3XYMs=;
        b=RAW3jr+d9gBy6wm0gNLJ+Zi9orjJ8SdJV5fMvxWUm/Croi3eJy/KVp3/p22L/x9SDR
         1w75K13nzx3KTgRYGJzMxAkcPfmRazr0BFDxev9OJR30oXeLXJ3tm7A/gRtAwB2gq7cD
         Awud9/1F524V1ABlnDe5tllbg3X+rmA26VGHX/uEmJavQDsisXGRTHwoVNo7PIX1fGo7
         twRKzcMwdaD5cegChAtCJzxoeWDJi0L8zETvx7bR3lj2WEloL2wQtFzYtgNaZ0nhyiVH
         EX8ncguuG9FYNQSwbBiYbJ8KseAL0vY3z14rQvebFMfVBjCTMkOHWUKWr6gyNfq/fRcT
         DxRA==
X-Gm-Message-State: APjAAAUolxTYoMm5UFmIx/2YDWWso7SIM+FlgTDRh5u5k2JkbOf844g4
	67oe2VpfaIPjf30+tv4sFaVW0lMUF/FpIiSuXOLqe/9gWd9rT5p/tmHUtybOuNuWu0hFyp3v9T+
	6WotaUnn7lAxmvFsstxKA1KJm5vZpR9vzY6K88tSXfLlygAMzXAnBwPcC92yuEwShZw==
X-Received: by 2002:a17:902:868f:: with SMTP id g15mr87998988plo.67.1560439681712;
        Thu, 13 Jun 2019 08:28:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxgihb0j5qaHysl+sk8uWHIaWuT6Kvz9xfs803ud37o2DK5eNaHGnUGIFQzqdj4xU31J0Sf
X-Received: by 2002:a17:902:868f:: with SMTP id g15mr87998925plo.67.1560439680991;
        Thu, 13 Jun 2019 08:28:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560439680; cv=none;
        d=google.com; s=arc-20160816;
        b=XChwqqFIRFAInZ07STOJn5pWwEVzoZPK/HDlZAiBELR1jHTmywd0ILGjhtt5t7CzVQ
         zSF5pcddE2EyRIFR+JYUHcgqzVZm+YB9Ze5i67zXMIiCDcvng57JBYCX8cdwES4IyMRr
         FnowlPPSuxsWcYtwkskd0ZwkLn0rn1Z4amoeoE9i2psztgww4bYO1lh5zfp88gwocYy/
         2lo2K5yLGrqzeTq0Gizi8AQNxPwzbX9HRpEwM1shUorKmW+rHJRNRyKbRklA1xohjHHd
         idGkXu++t6qV0u01oRsNcDmOQYv8nKW81iIxdwmwhd12CsVrekoK5Wu3wNIh0nLKrSnp
         AFoQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=vn04L/39CxGmnFvWZbLFG3AukuBPlzgMR3HJ4g3XYMs=;
        b=k7uySIHGqkMC8pMbI4sJngZDH4pKAmmHdBK/hQrb09+N7ZiVvBEHR/5HRKPpBebKNG
         bFeQ62GD70BkdoDTe1lBuorzc200zenk09Ifb45r5xL4UuMUDm5xsjyDqgdO7foKE+cW
         hoK52LjSPuHZub+MuV5X45bXTtyznspP1eDpYqeirmMChoQcvxyxTkDJMFniAdyPGk4l
         I7qN80XOxzIgaUBZE25Q9w0ST5yCyeIfHdnSmeUvEAr+Mqt3tPTwTnMiTLs+FnJO0Pgf
         mrdezgCvobTWkOZPEI4acLqjE9UJncYxCEGU3qbTEbZ8x25mAaFImVwhRe6ot39z4nnI
         8TJQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=tHlQpyqz;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 100si3477835pla.158.2019.06.13.08.28.00
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 13 Jun 2019 08:28:00 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=tHlQpyqz;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=vn04L/39CxGmnFvWZbLFG3AukuBPlzgMR3HJ4g3XYMs=; b=tHlQpyqzo7ZQBVB5wRrQJI46t
	aGvrn7sclf7JSvki0K76DhAQ9grt++rr3RsyMukb0ZOE6ao5QkZuVltTGW0kSmf01kovvUtAmSiMC
	FRCnkWcmo+pTrNeUZtpZy52SEQbCrGAv6HRyCq081N6v+J6AluX52Ap/rjGwfAbZNww9f9q25CrJ4
	2/28x8clrMHc5fH8S/5jQZoozJIYzfzvecMqlkikJzXv1MdjRaDtLgMF0+C/+TZhLxUqIdCboLufF
	QARq/0WKMHCQBh07+I4aQgQBCb/hzuiZZD053C7PNwE5NpsajGwqxDMtci1Q9lcRzIGXjOlZwRRQS
	8bRUD+XPw==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hbRdr-0002TD-Ht; Thu, 13 Jun 2019 15:27:55 +0000
Date: Thu, 13 Jun 2019 08:27:55 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Ira Weiny <ira.weiny@intel.com>, Jan Kara <jack@suse.cz>,
	Dan Williams <dan.j.williams@intel.com>,
	Theodore Ts'o <tytso@mit.edu>, Jeff Layton <jlayton@kernel.org>,
	linux-xfs@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	John Hubbard <jhubbard@nvidia.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-nvdimm@lists.01.org, linux-ext4@vger.kernel.org,
	linux-mm@kvack.org, Jason Gunthorpe <jgg@ziepe.ca>,
	linux-rdma@vger.kernel.org
Subject: Re: [PATCH RFC 00/10] RDMA/FS DAX truncate proposal
Message-ID: <20190613152755.GI32656@bombadil.infradead.org>
References: <20190606014544.8339-1-ira.weiny@intel.com>
 <20190606104203.GF7433@quack2.suse.cz>
 <20190606220329.GA11698@iweiny-DESK2.sc.intel.com>
 <20190607110426.GB12765@quack2.suse.cz>
 <20190607182534.GC14559@iweiny-DESK2.sc.intel.com>
 <20190608001036.GF14308@dread.disaster.area>
 <20190612123751.GD32656@bombadil.infradead.org>
 <20190613002555.GH14363@dread.disaster.area>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190613002555.GH14363@dread.disaster.area>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 13, 2019 at 10:25:55AM +1000, Dave Chinner wrote:
> e.g. Process A has an exclusive layout lease on file F. It does an
> IO to file F. The filesystem IO path checks that Process A owns the
> lease on the file and so skips straight through layout breaking
> because it owns the lease and is allowed to modify the layout. It
> then takes the inode metadata locks to allocate new space and write
> new data.
> 
> Process B now tries to write to file F. The FS checks whether
> Process B owns a layout lease on file F. It doesn't, so then it
> tries to break the layout lease so the IO can proceed. The layout
> breaking code sees that process A has an exclusive layout lease
> granted, and so returns -ETXTBSY to process B - it is not allowed to
> break the lease and so the IO fails with -ETXTBSY.

This description doesn't match the behaviour that RDMA wants either.
Even if Process A has a lease on the file, an IO from Process A which
results in blocks being freed from the file is going to result in the
RDMA device being able to write to blocks which are now freed (and
potentially reallocated to another file).

