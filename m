Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 63800C10F11
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 14:19:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2903E20835
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 14:19:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2903E20835
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BC1596B0005; Wed, 24 Apr 2019 10:19:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B71126B0006; Wed, 24 Apr 2019 10:19:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A613C6B0007; Wed, 24 Apr 2019 10:19:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6C7866B0005
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 10:19:40 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id j44so9277576eda.11
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 07:19:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=5UCoUvXLO0M/TdfgfzJq1Fxq7YLxeYuDRR3bQbQyeNE=;
        b=pYiVV+JoNa4gdOE9ZzCLeCCx8qmlA+B98GTIXXbh9erNPWDx+wNQXh17uhyhwNZtpd
         Smyl+WY6EslzrWPyxNwH5ajuItVgb1bWCTW9FxJUY9ipiLCTffgdNSTDzWapQRpImkjZ
         Rs1nfd2zkQ6Nc1CwxWtM4I4PTcP4KB6zywiziHvRSX5fZCsvsZQvUf4VesDrj6LMTUMf
         ZyLSru4AmrxbDAFYBNQT8y0qZ9ptRG/zPcYtCqLVxcRmvBDL+cPZ1Ef8mQ0tFDOUWHMP
         CCiQPWQnqBDekH/M3+GK+Ika5IoTdIjTqslxRF0JqkBxLGc6e1utP3J+FsWBkvICFbRP
         S5BA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.39 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: APjAAAUlKGZHJdIZJIWidcTpCJLqY8JECy5+1qrG5EKUGOLIaSNtQ0cy
	MxC2o3LQe5FYUG+XvlFR3nfDHX2enatw+IknnaPspORFbGp0oQNUFQJ7kYLcNc0+0u8ar0CXrpK
	to55Gii0jOuLjxSgvHKMkb0ti/Y10BHLA2ftzOjYb1J1s8TqdTLY1kXytTYPyZST2Cg==
X-Received: by 2002:a17:906:6051:: with SMTP id p17mr16377323ejj.243.1556115579941;
        Wed, 24 Apr 2019 07:19:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzd24QyhWt1PBJh/QPWNUQUGR3x8VywESmMJdebBrIwWrDTrnXNj28NgLVL8cGB34c/qz5m
X-Received: by 2002:a17:906:6051:: with SMTP id p17mr16377284ejj.243.1556115579020;
        Wed, 24 Apr 2019 07:19:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556115579; cv=none;
        d=google.com; s=arc-20160816;
        b=aU0Y+g5yCBjdF7zoxUtxULg1Ucwf9CpLgPjSN3uril3gr3dZVoKGkJe8HZXX/cFL1x
         +TTRz6oWTZyvJ1VJj9PE6Ic+tsZtTicJuPtkcm+E09ZWIdst7locn7C1S5ZBJPLm7lOy
         IqEh5ES6xmJyippzgPhWTZueuBiEvUcQ8PqIfCXQkVa5JvPDA1OUOAutnzumm79noYxv
         bJxMM6ConIYxuxQc02kN9qix+6NjbyjbmtyphbU/09PAr9owNUYfL0RD5ah2bIuJQuw4
         ITlhZdDfy4+wKn3ioSjD2WlepaA13Kw2ibaGk81c+xg1+RUTr/LwCAmISsHzcTpwShvA
         y+ww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=5UCoUvXLO0M/TdfgfzJq1Fxq7YLxeYuDRR3bQbQyeNE=;
        b=psqLcUjdr01NShzrxU68XlORjdGxOkS2iH09J8ZhcXRQXNXPHanKRooOcpG7jifPPs
         XW1NQ4PO7IiQF2U5Su2TjETWOV8xQgcdmH56GxKpWgWKs7gI1iL7yilwiRlJJEcLFTMK
         4g/prQ+h0z2gNvndJfhXAmPMgy7N98wcS0z6fpphMEsmkJup//LstLBgObbXBN5o4qQd
         QYRBcFZSg2kwYXkj3F80NdxD67NYUlzFIUVLB//snr37EfecRYfqoWHjrjWEhrcBUMcv
         Se8MFCRbhq5y3tX5qy3DkIttB+tLsE8I+ipU2KltFJB1/hBdCAxHzyKHA5gVjPe4ie9s
         T9ag==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.39 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp06.blacknight.com (outbound-smtp06.blacknight.com. [81.17.249.39])
        by mx.google.com with ESMTPS id a10si3346698edq.180.2019.04.24.07.19.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 07:19:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.39 as permitted sender) client-ip=81.17.249.39;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.39 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp06.blacknight.com (Postfix) with ESMTPS id 47FF198852
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 14:19:38 +0000 (UTC)
Received: (qmail 21430 invoked from network); 24 Apr 2019 14:19:38 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[37.228.225.79])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 24 Apr 2019 14:19:38 -0000
Date: Wed, 24 Apr 2019 15:19:36 +0100
From: Mel Gorman <mgorman@techsingularity.net>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Christoph Hellwig <hch@infradead.org>,
	Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 1/2] x86/Kconfig: make SPARSEMEM default for 32-bit
Message-ID: <20190424141936.GU18914@techsingularity.net>
References: <1556112252-9339-1-git-send-email-rppt@linux.ibm.com>
 <1556112252-9339-2-git-send-email-rppt@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1556112252-9339-2-git-send-email-rppt@linux.ibm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 24, 2019 at 04:24:11PM +0300, Mike Rapoport wrote:
> Sparsemem has been a default memory model for x86-64 for over a decade
> since the commit b263295dbffd ("x86: 64-bit, make sparsemem vmemmap the
> only memory model").
> 
> Make it the default for 32-bit NUMA systems (if there any left) as well.
> 
> Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>

Acked-by: Mel Gorman <mgorman@techsingularity.net>

-- 
Mel Gorman
SUSE Labs

