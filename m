Return-Path: <SRS0=Mdb/=TC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 14211C43219
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 19:28:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BFA82205F4
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 19:28:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="anlXyzLH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BFA82205F4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5C9F36B0003; Thu,  2 May 2019 15:28:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 553356B0005; Thu,  2 May 2019 15:28:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 41C936B0007; Thu,  2 May 2019 15:28:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id E4FEB6B0003
	for <linux-mm@kvack.org>; Thu,  2 May 2019 15:28:33 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id c26so1541718eda.15
        for <linux-mm@kvack.org>; Thu, 02 May 2019 12:28:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=2BtVF69qKBrz9RiY6v2/KzAanhM7UTkuvfK1eqLRPts=;
        b=jM5gLjeMham/yzgqI+k/++2ZbeOxi4V1IKq9k4KZiwADw6GkR6e2pm4BxO2Pz0gd/v
         j4jqIn0vQum8ApoVyXOxwEogcGcRbz1QrR+sjKt7U1k8yL/KvbyYIY9O/Ek7+HHRxUyg
         gHYlvrJjJzJ/8GOH6OWaB/sPGXyokVeOidIjL4mHjwsnlKoI46td18SOBLqohmlGQNGB
         eBfMHqejoxxS67hOax6A/FITo0W6LOZEfOraYHH7TNSTuwy0Pvu63J3ZoNtOowGrHK3W
         7vL39OMfJvTVIrfzzRkeVt/d8uPfkiHOg1UHx8CERnWx3oMCtdLcNtZ9UfGMRyilhaCD
         JXzg==
X-Gm-Message-State: APjAAAUeJMcYwZyzFNlK2j/bCVx8Uw5VCj8QCqF0perp6RMU8jDyvMuV
	u6sCAg5IJj+GtqtCOXqc43XeEHCrbTW8OFXtEnF+jk66wGfitY8uyhlFx/XsZIksPIJdXJK5GvX
	IfvBmNwqHKZh0sitxt1DyNP8YwLOHkJONsb7h86KKwYEyJTbUHCyGP0Gaw+a8T3Qc4Q==
X-Received: by 2002:a50:84e1:: with SMTP id 88mr3704183edq.193.1556825313423;
        Thu, 02 May 2019 12:28:33 -0700 (PDT)
X-Received: by 2002:a50:84e1:: with SMTP id 88mr3704153edq.193.1556825312748;
        Thu, 02 May 2019 12:28:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556825312; cv=none;
        d=google.com; s=arc-20160816;
        b=wcCWPlVLQecaps+0QO+rS8599awisJ3RLeH28WieJkG5zyhA34vrGo6jjyxwVU0uVM
         ST0WHF2jebIS5lp/jBqtf9c5ePS/3yIrMOJui4lMSesXlyR9una85/cLCtYcdbAbBQZi
         zWNpNermmatZaMgxb5cfGKzZWGy3NDpxlKgeLTDnxFW+asV4sdVi77Ij2wTACNbypI6L
         FJaAtCNCCNPwYUTryrKay7zsCdJsESx3yuWdXR2x4/ZP0Hs8kXRPXuBw6E1zSM8BFmSX
         go0ikp/dhBqxHvDcliQPrSzxvNvOXL5xWQR+rG2jCtmjTXXsvKijimerbQmwrtuwh8kg
         pxhA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=2BtVF69qKBrz9RiY6v2/KzAanhM7UTkuvfK1eqLRPts=;
        b=KK7Va1jicZMQ8JpTZWyC/PBUCYS5F58DFlpUNq0+9xDs/kfoklF6H9uab1BlAnINtz
         J4bqSVUvfJjuPMxP6dPFHOUEg9/Os4C3CqIsJtqvyBRHSQcykuR4GhfBsOJEmkLPx33M
         NPUZz4YP1OyEBQbmoIBTAcVs0PhLgFd9Yj9oo8WdxUlZC+B9j+Tc7DKGHjbtJ0d5jRnP
         iJEbDuvhWJVTOFCLpRBrrTZG/CH16rylzg4Y7BiRqzb7SUueaWJ+dQ6ETNH6bNrjgq6F
         YYtTyHIyOcyrI55d5tYMbJ2cuI616mpKTXjy0b0+Z8op8OUqBR3C5A62MCQTlI1WvRHt
         5rVA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=anlXyzLH;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q12sor7982438edd.18.2019.05.02.12.28.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 02 May 2019 12:28:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=anlXyzLH;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=2BtVF69qKBrz9RiY6v2/KzAanhM7UTkuvfK1eqLRPts=;
        b=anlXyzLHl7/mu36RIFAIxcKsrMSkce8RmXLT6gA8XWonyrduEZz1Kg+UsC5D7z8FMT
         pj/5pMF5ClMHohgj3ZkruEIp4c2E5vQjyL591Z6YSXLnoKPyWVamFD6tN0pTpi2Xf+h/
         6EzBRSlftPpfc3PWdfVmuQ20DUG8J6I1uPHl0PHVXqEYgJSmeLguWSTy+gizwQEVh6D4
         zU9Rll/WLv1aAxKOG1/NLVtaNEEZD0tv0yxKuRd4XH5bskMKWYH80Kho+m1Dm+hRb0yt
         zHtzKyeb1W4lTDOJ3OHpU0hw3N/Lnedq8p2bBwEGvzkeS6cCOEC/t+VkwYNJtyLd9K+K
         BM5A==
X-Google-Smtp-Source: APXvYqzhKsKRt3YYywySk19JgdcvKgG4zttzP8aHLHqRlNIg61SzvLJCSfVQUqqi+2uhnhEboRWyoEvmzKYQf/GF1Ns=
X-Received: by 2002:a50:b4f7:: with SMTP id x52mr2879275edd.190.1556825312425;
 Thu, 02 May 2019 12:28:32 -0700 (PDT)
MIME-Version: 1.0
References: <155552633539.2015392.2477781120122237934.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155552636181.2015392.6062894291885124658.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <155552636181.2015392.6062894291885124658.stgit@dwillia2-desk3.amr.corp.intel.com>
From: Pavel Tatashin <pasha.tatashin@soleen.com>
Date: Thu, 2 May 2019 15:28:21 -0400
Message-ID: <CA+CK2bAfw=pkYF2Ux-PM5r7U46JbDA-fM3NjQ3a5F_Fs0D0GHA@mail.gmail.com>
Subject: Re: [PATCH v6 05/12] mm/sparsemem: Convert kmalloc_section_memmap()
 to populate_section_memmap()
To: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, 
	David Hildenbrand <david@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, linux-mm <linux-mm@kvack.org>, 
	linux-nvdimm <linux-nvdimm@lists.01.org>, LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 17, 2019 at 2:53 PM Dan Williams <dan.j.williams@intel.com> wrote:
>
> Allow sub-section sized ranges to be added to the memmap.
> populate_section_memmap() takes an explict pfn range rather than
> assuming a full section, and those parameters are plumbed all the way
> through to vmmemap_populate(). There should be no sub-section usage in
> current deployments. New warnings are added to clarify which memmap
> allocation paths are sub-section capable.
>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: David Hildenbrand <david@redhat.com>
> Cc: Logan Gunthorpe <logang@deltatee.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>

 Reviewed-by: Pavel Tatashin <pasha.tatashin@soleen.com>

