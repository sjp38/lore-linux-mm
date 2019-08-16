Return-Path: <SRS0=YXmN=WM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 29FFFC3A59E
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 13:21:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E45DA20644
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 13:21:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Bdoe+EPy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E45DA20644
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7ABC76B0003; Fri, 16 Aug 2019 09:21:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 782DC6B0005; Fri, 16 Aug 2019 09:21:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 697EE6B0006; Fri, 16 Aug 2019 09:21:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0168.hostedemail.com [216.40.44.168])
	by kanga.kvack.org (Postfix) with ESMTP id 433226B0003
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 09:21:17 -0400 (EDT)
Received: from smtpin26.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id D53DC440F
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 13:21:16 +0000 (UTC)
X-FDA: 75828352152.26.mask62_62700e5544e14
X-HE-Tag: mask62_62700e5544e14
X-Filterd-Recvd-Size: 3995
Received: from mail-pl1-f182.google.com (mail-pl1-f182.google.com [209.85.214.182])
	by imf04.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 13:21:16 +0000 (UTC)
Received: by mail-pl1-f182.google.com with SMTP id m9so2444982pls.8
        for <linux-mm@kvack.org>; Fri, 16 Aug 2019 06:21:16 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=dm2N+LnWuHtZbkuSIck0zIcrvDsNHqwjs1kno32i+NQ=;
        b=Bdoe+EPyJIVt0t4vtNlH3KtR97Uv+lIglmMvP9oVETaOhMb+OsBJBYdKEl2FqG4npb
         FKKbloJWQQBhLJ2altHF5EOizbJD3qSmt9okzqqKsWIRYBdLEkGtHFs731ihxLty3TUC
         kgkjyN94T3r46VAC0bHTLz26wdM+WhZbYjLXu02lqXIpfyQhRTerQwuAXbuTqsDBdLWE
         kvXX2rTNUp0qb4+8nmSkJzJzCJZ4bt3wSyu48WnFkf/FIsDIjvn4FA8eb6ZNa9/Jhq3C
         aC6fMBrfgQKu9fiGJZ4ESItwoOimDspMMwM5F7upsNxUdKmOmfd8C+9gfuH28qCDi0Vb
         9HpQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=dm2N+LnWuHtZbkuSIck0zIcrvDsNHqwjs1kno32i+NQ=;
        b=dJB3ZQfrTM+BgD6Wy06sg0pNn4QHtvDN1X+HYdYVWAZDSMT7CGIUx+ADO3bs0+mifX
         LQgkSc205cZd4L7Qk3V0LQH0CSxXOjx36WaVVw04d6v8HIgGgt2afaKta0zDBRRSY49B
         H24rTXMRyyGYd7hASIYWA7VN6JUoz8M+FzINeLWTjGi5v5rEV6AQxF1QifewqHY/b1bD
         f1xvJWgKJxhaRXdplc2XCzScaGUgAFYJ/It9GID9NYolLiJ2wFtNhJNwxCCl9LhrChTb
         PdvBe9KVo2IaWYzWwUGF02bc8f77QUS4iBsf9ZyZbb45W0t+8gtXXCpLPuetD5LWRfAE
         N6sw==
X-Gm-Message-State: APjAAAW7enuVnzLFGofmqLv4Y9zKOjK9P+1AKMayN/RVkEUfhIxkUyzq
	bI19+HhZDZo4sHAnC/fM1g==
X-Google-Smtp-Source: APXvYqydGyP1mgEtu3qW6HKoHuLtWSwwvIrW5xwjx4KYVdKuvGs6ug/t1qFEg81KA7jnC2oBLt7JpQ==
X-Received: by 2002:a17:902:4401:: with SMTP id k1mr9272692pld.193.1565961675287;
        Fri, 16 Aug 2019 06:21:15 -0700 (PDT)
Received: from mypc ([209.132.188.80])
        by smtp.gmail.com with ESMTPSA id d12sm6107656pfn.11.2019.08.16.06.21.09
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 16 Aug 2019 06:21:12 -0700 (PDT)
Date: Fri, 16 Aug 2019 21:21:02 +0800
From: Pingfan Liu <kernelfans@gmail.com>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>, linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Mel Gorman <mgorman@techsingularity.net>, Jan Kara <jack@suse.cz>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Michal Hocko <mhocko@suse.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Matthew Wilcox <willy@infradead.org>, linux-kernel@vger.kernel.org
Subject: Re: [PATCHv2] mm/migrate: clean up useless code in
 migrate_vma_collect_pmd()
Message-ID: <20190816132102.GA10848@mypc>
References: <20190807052858.GA9749@mypc>
 <1565167272-21453-1-git-send-email-kernelfans@gmail.com>
 <20190815171918.GC30916@redhat.com>
 <d0a8ab6e-1122-a101-6139-9d7dadb9e999@nvidia.com>
 <20190815194021.GB9253@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190815194021.GB9253@redhat.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 15, 2019 at 03:40:21PM -0400, Jerome Glisse wrote:
> On Thu, Aug 15, 2019 at 12:23:44PM -0700, Ralph Campbell wrote:
> [...]
> > 
> > I don't understand. The only use of "pfn" I see is in the "else"
> > clause above where it is set just before using it.
> 
> Ok i managed to confuse myself with mpfn and probably with old
> version of the code. Sorry for reading too quickly. Can we move
> unsigned long pfn; into the else { branch so that there is no
> more confusion to its scope.
Looks better, I will update v3.

Thanks,
	Pingfan

