Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 329AFC76197
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 08:46:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0417C208C0
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 08:46:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0417C208C0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A45BA6B000D; Thu, 18 Jul 2019 04:46:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9F5C38E0003; Thu, 18 Jul 2019 04:46:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8E4648E0001; Thu, 18 Jul 2019 04:46:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5112B6B000D
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 04:46:58 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id m23so19535985edr.7
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 01:46:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=o0WVbsx8xs5m+g/6SZ3qMvPCcq061WLxlFZJyJ+V1Bc=;
        b=otOeiLxb8W6wZBd48Hy5ifkt3z3Ocfa7wXY1mPSyJJEAFIMRiwztFIto96i2NXK+k+
         K/puE7caIKA3O7jBW2yxvDPxhTM6FruZbTKZIgK2veMHGVm6kkdVlKGKBH7dXNRQWBJk
         utL1lRCBNIV1raUcoFXrxXW1LpWJ+qH5ZvM0yOXVRhO7C2v4horZwGHCj78JjzB6grbJ
         xv5IvxGUiJGqeTRg1wTfIosOu4mm7Nwr+dzq7CfTFgNmDCNi2rtPmxE/+QMIo4u4e+U6
         bbADnvUTqOGbr6x+L2yK05VZHA+qfYfHCWjllYTMwC+QTPTCXlBi3OFrvBtJ6NroqUyH
         wlYg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jroedel@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=jroedel@suse.de
X-Gm-Message-State: APjAAAUrgPDSxzsyikJZuHlVGncUZlO7ucj9BQ1fjTTA9syc+n4Uc83u
	I3hpJzNdijHG3WRxdll62znuT3WmkwO312GS/iC+TwY7J8evAh/4WLM1PdYerSPWhFw+sIr15NV
	w8kN4Ps1SOzPzl9PkXVkHmmKO+reLzE94//hoMadS0O126Anv0sC7kT1uQr268+j6nw==
X-Received: by 2002:aa7:cf8e:: with SMTP id z14mr39362706edx.40.1563439617848;
        Thu, 18 Jul 2019 01:46:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxrmK5DK/Za4cCbu3kG6NoiZH3fuhGccb5wbYddvD6Yq5wL3qRxXWyLfnumsXA81ty7Tnsq
X-Received: by 2002:aa7:cf8e:: with SMTP id z14mr39362670edx.40.1563439617273;
        Thu, 18 Jul 2019 01:46:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563439617; cv=none;
        d=google.com; s=arc-20160816;
        b=vVqkFm5D2qBZl0n6PmS4r7c4DZnoxCcADUXmQywrZJ/BwZXOZOFaUtlTy9yV690yAb
         CYfEfAkjCC1UMatv+johND31WGqZ1qpGhK8QR9ZvL2B5x1CKFbF3YIrPhZQMLnkkCrS5
         Hr90VcZ8K5qD+PP127oM7YS/lINIDcigt7UMr9ZHIFAb+bqAIIN8Ezlg76vpITcaSdqG
         0zYmFE8sSTest/ae7dqAbsh3yGAsmnXxzrucS4wWecXBzfZbLr5IwRd0LkcCLlwmeQxm
         pKtNkD/Nd35IZgshAGq6qo7xyAQVsZYbBYJMP8NkUnpbVKiCslajWuVkfriSN9SivQNd
         eOow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=o0WVbsx8xs5m+g/6SZ3qMvPCcq061WLxlFZJyJ+V1Bc=;
        b=dGFTyfcyWtRohEFpgxfvM8Zgx5Hh/p0TSJes8ggAP1A8g07YnBlYDkr5UcTtguaARU
         JL05CdNGk+fpARH2tbfhMystwgrchwVbRqW1dqK8qInnrihGM8OjXVX9BAQo9zEQaJ1d
         LMVloCBOCB0yUWy9WLS+ksjuMgrlJ5wqUYRucRDwI98Pt2kCO88lq8Rjv3zbAtOWZkNv
         hJeM+uSvAkCuVJ5MKDq4fJONF9liCCcIbG1r0ffMb1VC3KkMss4fk1u7UsL94/mrmJB6
         EnVfyf9ufffjGFw4CyGZUz8TotCWHJqoDXt1lEwzdgIr200hSCR0P5tB1n5S2Og7k53P
         yEaw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jroedel@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=jroedel@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 32si243343edr.287.2019.07.18.01.46.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 01:46:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of jroedel@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jroedel@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=jroedel@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 87F6FAD7B;
	Thu, 18 Jul 2019 08:46:56 +0000 (UTC)
Date: Thu, 18 Jul 2019 10:46:54 +0200
From: Joerg Roedel <jroedel@suse.de>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Joerg Roedel <joro@8bytes.org>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Andy Lutomirski <luto@kernel.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH 2/3] x86/mm: Sync also unmappings in vmalloc_sync_one()
Message-ID: <20190718084654.GF13091@suse.de>
References: <20190717071439.14261-1-joro@8bytes.org>
 <20190717071439.14261-3-joro@8bytes.org>
 <alpine.DEB.2.21.1907172337590.1778@nanos.tec.linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1907172337590.1778@nanos.tec.linutronix.de>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Thomas,

On Wed, Jul 17, 2019 at 11:43:43PM +0200, Thomas Gleixner wrote:
> On Wed, 17 Jul 2019, Joerg Roedel wrote:
> > +
> > +	if (!pmd_present(*pmd_k))
> > +		return NULL;
> >  	else
> >  		BUG_ON(pmd_pfn(*pmd) != pmd_pfn(*pmd_k));
> 
> So in case of unmap, this updates only the first entry in the pgd_list
> because vmalloc_sync_all() will break out of the iteration over pgd_list
> when NULL is returned from vmalloc_sync_one().
> 
> I'm surely missing something, but how is that supposed to sync _all_ page
> tables on unmap as the changelog claims?

No, you are right, I missed that. It is a bug in this patch, the code
that breaks out of the loop in vmalloc_sync_all() needs to be removed as
well. Will do that in the next version.


Thanks,

	Joerg

