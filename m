Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D6F33C10F0E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 22:24:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A1A2A2064A
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 22:24:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A1A2A2064A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 522576B0005; Thu, 18 Apr 2019 18:24:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4D2DA6B0006; Thu, 18 Apr 2019 18:24:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3C3316B0007; Thu, 18 Apr 2019 18:24:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 06EF56B0005
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 18:24:34 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id v16so2214902pfn.11
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 15:24:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=aA9zcWjkQt5q4swM/DAfqtwYnHQBxTvTRaWHqqz/mZo=;
        b=gTNG69ExrkH6VwEgO0np0l8V8+xKBH+2lJBDj8BDLhKw86OWnq/moaItZTWvzrVVSK
         InmVFu53A8zX0AuHnfwUbLFRe+agmsY+6LRp9pd8G171y6vPJWj7f+g90jwx4WGdKwX4
         do20pNb8PXANPqWOfJd1aGolOL2I2x8o1b3mNlWQzE9622eIP04yq4gr0uxB7tWHaLDX
         vCIXjl0NhhDCp7tFHkwaRuvWEn5+B4PK2V04YD2HJ+VPoKmZdPL6g59GNkC/6ByU2T6e
         WVkGy90GBrHm6UG9smw5Ylgea3+oUVvSRS3GdwzkCjCikuvBN2wbtSoJfb2XG7n2R5ze
         O7DA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAUuqVzGpW+UqTJ18jTN7061FvDCM+jhUEhppuh8i2UjXNhFQGl6
	w1ZnBOwO38tXYOM0wp3LurUICCw5rNV0g/MnHdV3qhTeSV2u8AIKSlvqWl9oQfg1oiWL2tZ82WT
	P3YciImz+xGR/pDo16jACJ2csHsJy9CKcRb/5VUU30bb8BUk1KgkZQ0tGS8pYk39PKw==
X-Received: by 2002:aa7:9466:: with SMTP id t6mr119616pfq.246.1555626273642;
        Thu, 18 Apr 2019 15:24:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy0gLVlHTHdARFVJr67abI2n+z6ZmlPoOnQo5BTxuGXg/Paa9ucoYaIHrHEr6uaozE1M6e5
X-Received: by 2002:aa7:9466:: with SMTP id t6mr119570pfq.246.1555626272930;
        Thu, 18 Apr 2019 15:24:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555626272; cv=none;
        d=google.com; s=arc-20160816;
        b=ecTZLfkTQYE7G0raBA6XunBOrfDYOVBZbrv8s24+y5cQFPu9MRKIY93vMeK6qoM8ME
         OBiS0tCS5sdDbcDDq3CCCVIgtt4TIJx0YuXADvSfAc5X0WCjeifu0pr2wQ0BqkTbC7VW
         Ik7tU4EbKim2Yx4TffeQSBtWMr14R/QKzEPJcmyw8k4RJbS2uhmSE6rLdFyPkH/qDMcS
         zLxZqzgmX1iEjjaDgQeWLaZbRCQTWAB+ofnaD1CRmEXD7Fpyx20lXdsKgjk09M5iT0cC
         qHMOpMw6HLh2kPg4uV4cJyiRdqv+It6KbJg/XXNZVBAOPTJd2UiPOf4NxPfi5DjQvaxn
         RM+g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=aA9zcWjkQt5q4swM/DAfqtwYnHQBxTvTRaWHqqz/mZo=;
        b=MrKv/PRzf4Zrn8uSVHr/QwDFBFWaE5HPYM1xDFAR0GJ0h8xukozsmiichRzyo2d69e
         fajn3s3LrzwnxxTFfVkpHIiQR2Pv1ZtO/FWO/E2LutUmdwM/WsveU11xCvT+jYMilEzF
         /bufIXGaqecPNU0huMmpEV6BaqBrz3dLvF7aOGe1cQwvh79UF3nDIuSRAz+z3aHNii6w
         rR0dnz0rsED+OUjXcGLQ6niUF6sVXd5N5HYIOmgZpfN2PDWwZxqaX1XUXCpgU+19Jlzt
         Xdb2G/quDWTdInwrLLMOPdZA1n3k7R+NfSI8kzuaTZecaV22KIhJex1n5oESxLxPoM/x
         DS/A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id y7si3060205pgj.274.2019.04.18.15.24.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Apr 2019 15:24:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 584911F5A;
	Thu, 18 Apr 2019 22:24:32 +0000 (UTC)
Date: Thu, 18 Apr 2019 15:24:31 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Roman Gushchin <guroan@gmail.com>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, kernel-team@fb.com, Johannes Weiner
 <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Roman Gushchin
 <guro@fb.com>, Christoph Hellwig <hch@lst.de>, Joel Fernandes
 <joelaf@google.com>
Subject: Re: [PATCH v4 1/2] mm: refactor __vunmap() to avoid duplicated call
 to find_vm_area()
Message-Id: <20190418152431.c583ef892a8028c662db3e6a@linux-foundation.org>
In-Reply-To: <20190418111834.GE7751@bombadil.infradead.org>
References: <20190417194002.12369-1-guro@fb.com>
	<20190417194002.12369-2-guro@fb.com>
	<20190417145827.8b1c83bf22de8ba514f157e3@linux-foundation.org>
	<20190418111834.GE7751@bombadil.infradead.org>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 18 Apr 2019 04:18:34 -0700 Matthew Wilcox <willy@infradead.org> wrote:

> On Wed, Apr 17, 2019 at 02:58:27PM -0700, Andrew Morton wrote:
> > On Wed, 17 Apr 2019 12:40:01 -0700 Roman Gushchin <guroan@gmail.com> wrote:
> > > +static struct vm_struct *__remove_vm_area(struct vmap_area *va)
> > > +{
> > > +	struct vm_struct *vm = va->vm;
> > > +
> > > +	might_sleep();
> > 
> > Where might __remove_vm_area() sleep?
> > 
> > >From a quick scan I'm only seeing vfree(), and that has the
> > might_sleep_if(!in_interrupt()).
> > 
> > So perhaps we can remove this...
> 
> See commit 5803ed292e63 ("mm: mark all calls into the vmalloc subsystem as potentially sleeping")
> 
> It looks like the intent is to unconditionally check might_sleep() at
> the entry points to the vmalloc code, rather than only catch them in
> the occasional place where it happens to go wrong.

afaict, vfree() will only do a mutex_trylock() in
try_purge_vmap_area_lazy().  So does vfree actually sleep in any
situation?  Whether or not local interrupts are enabled?


