Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4C86EC32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 10:22:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F328F206A3
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 10:22:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F328F206A3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 583788E0003; Wed, 31 Jul 2019 06:22:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 533618E0001; Wed, 31 Jul 2019 06:22:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 421DA8E0003; Wed, 31 Jul 2019 06:22:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 05CAE8E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 06:22:06 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id l11so21174284pgc.14
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 03:22:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=CI+QmzpkJLk1Ebh5TR+N3+Bd4lL0dav5jMnhJ+GA7Xg=;
        b=i/pHjkfhgYmqVe0uZIJQMGWKbxqVp/mjAPxems387hKomsXzVjYskph+O5HIYrQ6At
         aSw8k7HRHB1LIka+lXscIQxm60zpzG08H9pzQz7egc09H+Z8uoVhBfnUY23DdrCl/THX
         2gkblXpfQrhZ5MAjjzrMmfE3B36hfZRi4860eSaLxSExWhyVZ9rkzdDC12Xanqo1PLSO
         5Bu7x8fO+/3oNiUhNPsu3jaX/LYq23usBzNPvazmGjtySsuxaGvxGTAKfHDmC6WWM2bP
         x7JPeDGok8r4e0SXymy0vZCsPeY/ZfjN2nmJL4RvRkPDgX6i5G6KAFzHDEO/VygU+BHQ
         FU2Q==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: APjAAAV+1CRY0FkwLBeuxOHXmIxacZ0J6H5DFgeHzd7sxt4BsX9hgZyN
	IlgnL74erSrq1vMOyeJOuekh6VoZly9ozsQfdl4IsSPoMwKgWImJlk0XVtBKDOACHNC5NBwSg33
	/ozB0en1eoAlGDDk3In/aNvYZzXJqiROcmdjmnh/3LWK0iZO9gcHEjOF6x1SdED8=
X-Received: by 2002:a63:fc52:: with SMTP id r18mr112955425pgk.378.1564568525544;
        Wed, 31 Jul 2019 03:22:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyNh+SpyMlDAMdzltIFjgYCFvYZuZr8JeKuIE8S2ANulRr6wrlIoOno7pMv0M/qS7k9BBDV
X-Received: by 2002:a63:fc52:: with SMTP id r18mr112955375pgk.378.1564568524714;
        Wed, 31 Jul 2019 03:22:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564568524; cv=none;
        d=google.com; s=arc-20160816;
        b=nD8NQ390dGpbzFQnnJBWxn0dxNSDD4FEbIMxG/RdopdHeRH3MDzX6qjEXjoBwadO4s
         ck2zD3ENRW7cR+EG7LEYdsjMBRnvbZMDEPyNn97KeKUKbVr4xPcT3cY2+wzYdJx0a6v8
         +10lZh7b4r0YsdmXmbbeYZ2XEiUamZpRpzwhioOiiulErwbJtyvJFObqIEkxMNfJxi8T
         YXGZtYREtW6g2JY5Tpun6W077tuz1wBobNLXzmyqtiBrRRtjViVNaBmeX+Ho+Il7qtp4
         lqiXc3czvQgR/qrlzIF21jFJOLdf8xWCfo66UyEiS7kEwZOJFxq3LX+Cx84tC7iGSJbR
         eMDA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=CI+QmzpkJLk1Ebh5TR+N3+Bd4lL0dav5jMnhJ+GA7Xg=;
        b=DS8OL7aMd8nS4w1Y/9U4CT+sqe7n8ZMRTv0Wt4MKxGp7IeoEMBgM++R3dM61k2DsaS
         /BY+ZnNmwh4u7G9lJJulZgL2LxPSIdVtHYExIXWUj8gSztMZ7joSzHGYtlm162oC29y6
         fAYZ0WJBbHMVIIErjnOlQ2r07QPw9bFuVZcV9tabeLdVlcK/r3cfSVRU6bbrvbdSjqHV
         b8WSuxsdKgiGAzETyNMt+ezk3junVwzFj5RjGdZyEoq4bHRNE+HBIwmdjwfo3pZ1rA7j
         dTefKH5qBMB8zz+jUNRqTLHJFNUEX4ughfG1N++aWYtaW1HH1vSIioSOlNZ2UwXYJQEQ
         u5KA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from mail104.syd.optusnet.com.au (mail104.syd.optusnet.com.au. [211.29.132.246])
        by mx.google.com with ESMTP id t24si32634478pgu.221.2019.07.31.03.22.04
        for <linux-mm@kvack.org>;
        Wed, 31 Jul 2019 03:22:04 -0700 (PDT)
Received-SPF: neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=211.29.132.246;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from dread.disaster.area (pa49-195-139-63.pa.nsw.optusnet.com.au [49.195.139.63])
	by mail104.syd.optusnet.com.au (Postfix) with ESMTPS id E23D943E0B2;
	Wed, 31 Jul 2019 20:22:00 +1000 (AEST)
Received: from dave by dread.disaster.area with local (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1hslj3-0005u5-Se; Wed, 31 Jul 2019 20:20:53 +1000
Date: Wed, 31 Jul 2019 20:20:53 +1000
From: Dave Chinner <david@fromorbit.com>
To: William Kucharski <william.kucharski@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Song Liu <songliubraving@fb.com>,
	Bob Kasten <robert.a.kasten@intel.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Chad Mynhier <chad.mynhier@oracle.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Johannes Weiner <jweiner@fb.com>,
	Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v3 0/2] mm,thp: Add filemap_huge_fault() for THP
Message-ID: <20190731102053.GZ7689@dread.disaster.area>
References: <20190731082513.16957-1-william.kucharski@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190731082513.16957-1-william.kucharski@oracle.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Optus-CM-Score: 0
X-Optus-CM-Analysis: v=2.2 cv=D+Q3ErZj c=1 sm=1 tr=0 cx=a_idp_d
	a=fNT+DnnR6FjB+3sUuX8HHA==:117 a=fNT+DnnR6FjB+3sUuX8HHA==:17
	a=jpOVt7BSZ2e4Z31A5e1TngXxSK0=:19 a=kj9zAlcOel0A:10 a=0o9FgrsRnhwA:10
	a=7-415B0cAAAA:8 a=BDTIUSf9NILoYbXAtJgA:9 a=CjuIK1q_8ugA:10
	a=biEYGPWJfzWAr4FL6Ov7:22
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 31, 2019 at 02:25:11AM -0600, William Kucharski wrote:
> This set of patches is the first step towards a mechanism for automatically
> mapping read-only text areas of appropriate size and alignment to THPs
> whenever possible.
> 
> For now, the central routine, filemap_huge_fault(), amd various support
> routines are only included if the experimental kernel configuration option
> 
> 	RO_EXEC_FILEMAP_HUGE_FAULT_THP
> 
> is enabled.
> 
> This is because filemap_huge_fault() is dependent upon the
> address_space_operations vector readpage() pointing to a routine that will
> read and fill an entire large page at a time without poulluting the page
> cache with PAGESIZE entries

How is the readpage code supposed to stuff a THP page into a bio?

i.e. Do bio's support huge pages, and if not, what is needed to
stuff a huge page in a bio chain?

Once you can answer that question, you should be able to easily
convert the iomap_readpage/iomap_readpage_actor code to support THP
pages without having to care about much else as iomap_readpage()
is already coded in a way that will iterate IO over the entire THP
for you....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

