Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1F83FC48BD6
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 22:14:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D2CEC208CA
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 22:14:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="pdYKAzcT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D2CEC208CA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 612668E0003; Tue, 25 Jun 2019 18:14:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5C4428E0002; Tue, 25 Jun 2019 18:14:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4B2D18E0003; Tue, 25 Jun 2019 18:14:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0F8728E0002
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 18:14:28 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id q14so196064pff.8
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 15:14:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=gYH8hOTIC6gdsY63nWGWhcZRgqkTY02tuzJXWawi/Xs=;
        b=K86Vxqtvxv8ewWy0RJxbMAWjun8TiGyFYDSudY83X1EhRPLljTVvmPZrgMUpy+yyqo
         6PexG3fqFA1vNfziqj4w93D8SUv3fX34/AIK8yXnJt/8UE2DJPcwr+Ylb7C01ElMa4Rg
         OtTs1DnS8rhiByVGXzV9XZR+ujyZcdzsv6du9EJHrCgbvaHw34wOmEnbFcr97gFevTQT
         ra5WlwUUR9/pclrbvuOx/2KDWEuwsMAxVNfo7IQcD7/kVyqA+S5Cz2lhfsd8/Ul3S1qL
         KVVBnJrhNC55mTKJZkP1urbZvDiz0cPTZ9lHp77WXpJkehBCPdkjde3ii6BKgNofTuU5
         9xQQ==
X-Gm-Message-State: APjAAAVEh+8ltj1mdE5xv6RgCHqdNX3CzLOde1yOZw1h/LqMXMgKJDmK
	SUFlBYZWKywfJmoYoLvGAGseagP2BO2fddA3OYkkg9pczRlOs7vmJ+wE1wyXHlFFLDaRuqgrzBI
	lCrDmrKNKfIwbgXDprv9GvQvSKrEGe2m9wGv5exixJrxolJsw70VhJ+1nh9s45IVgoQ==
X-Received: by 2002:a17:90a:8c06:: with SMTP id a6mr174294pjo.45.1561500867632;
        Tue, 25 Jun 2019 15:14:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqylzzo+Pi2y4hToQciCWa+Ro/qujikx/d+XsIkVNoBdkrWIKLYXjxFvXPsrWvWviBSKPi96
X-Received: by 2002:a17:90a:8c06:: with SMTP id a6mr174240pjo.45.1561500866887;
        Tue, 25 Jun 2019 15:14:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561500866; cv=none;
        d=google.com; s=arc-20160816;
        b=doQtodqmo5jUlIsp9R6MwbKGsvW63JQNo8lBjlcaeVi1a23HotqL7iOrUehl2Cwv6s
         6hgSQ7jFctUVN59y4+OOlk4CzcDiBiredJri4r6GuJoHstqzrWZpAVDE9pWH2i630woC
         fEHiTpG7HHOfQL9Jj7O8snlRlgCetB4Q7cMnEFa3HhBl3vFKoCTYDaC69Z9Tko9EdO4M
         19zLRxHrP5PG61Fdy2L41Tl1GAO1fK7Ybu0OCujrx0M/DgrG14XiQkflnrvuLNkMA5lV
         BIR0EvChN828JxtUSTAe1+QVuqYbymmdqWQ0JEB+M47UkA8ehVacLkUxVCjsI4wD8rdM
         QHDA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=gYH8hOTIC6gdsY63nWGWhcZRgqkTY02tuzJXWawi/Xs=;
        b=QWBUEGdoprITjgdy0PDY4lwK512zpv55pu5wuVsXBFcGDAkuY1CV6iEtxhaqWX/Bel
         Kn4HmrTpQNbUubEHDErxPejZgpgZRsU2q1LCQpj90pkMiNZbUgpgm6jxP/icfxLOm7O1
         joVLx6fnuhVqnm1otjAtgOzn4BAdtrbMvBPdOp+ibOIScYyyq1IpHwXOBtN1hZrqd6GW
         IemZUsCt5vERP6g+RUuekFUah792t92WPcBYxDnPzWbgBoZ7AgEdP+MnEt9IPq0CRugZ
         m0TCeDNr67M3CGqiXRP7rGLBY9mehNVfN8QfWrSI7rWwf4+sFD1WRITilrb+rxURIAS3
         1Qdg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=pdYKAzcT;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id l1si14882439pff.127.2019.06.25.15.14.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 15:14:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=pdYKAzcT;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 2B32520883;
	Tue, 25 Jun 2019 22:14:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1561500866;
	bh=a+8VUAm8OWcTl8Kv/cC5FFTkGEPWCMubfxkuqab8qY4=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=pdYKAzcT5/SVa+QZbQxLUBofTxIfjrpiHl88O9NdUIe7OEUO74C6mEsBMTxq3KRvQ
	 /8WwJ2fwOXLhXnNJ22SgZ6WP/7IhkzI8BoucLTD38qsRjbt/G3Hny1IiAePeFayjfH
	 VbPnXXtCaFR7V5j0uaxPzGR3oiA8Zm5lYytebzB0=
Date: Tue, 25 Jun 2019 15:14:25 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: ktkhai@virtuozzo.com, kirill.shutemov@linux.intel.com,
 hannes@cmpxchg.org, mhocko@suse.com, hughd@google.com, shakeelb@google.com,
 rientjes@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [v3 PATCH 3/4] mm: shrinker: make shrinker not depend on memcg
 kmem
Message-Id: <20190625151425.6fafced70f42e6db49496ac6@linux-foundation.org>
In-Reply-To: <1560376609-113689-4-git-send-email-yang.shi@linux.alibaba.com>
References: <1560376609-113689-1-git-send-email-yang.shi@linux.alibaba.com>
	<1560376609-113689-4-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 13 Jun 2019 05:56:48 +0800 Yang Shi <yang.shi@linux.alibaba.com> wrote:

> Currently shrinker is just allocated and can work when memcg kmem is
> enabled.  But, THP deferred split shrinker is not slab shrinker, it
> doesn't make too much sense to have such shrinker depend on memcg kmem.
> It should be able to reclaim THP even though memcg kmem is disabled.
> 
> Introduce a new shrinker flag, SHRINKER_NONSLAB, for non-slab shrinker.
> When memcg kmem is disabled, just such shrinkers can be called in
> shrinking memcg slab.

This causes a couple of compile errors with an allnoconfig build. 
Please fix that and test any other Kconfig combinations which might
trip things up.

