Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2AB63C4360F
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 00:49:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DBD98217F4
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 00:49:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="uQAnIj3z"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DBD98217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7B2F06B0006; Tue, 19 Mar 2019 20:49:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7617B6B0007; Tue, 19 Mar 2019 20:49:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6775D6B0008; Tue, 19 Mar 2019 20:49:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 284D86B0006
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 20:49:18 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id p127so845968pga.20
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 17:49:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=woHC6P4IWHeqMPl0bBWCL/dn49O6TQqdOp+Q3BiQuPY=;
        b=CROvxL9ufh5u76GnqXwUL8fcr66Xc1JgdeFZSbI/M3jj/+EMsSPwjamU5YsqopLVKQ
         FncNcHaOkeTHZVRD8TjNSV6niautEsrnbF/S4udnoFIQK9Cl8IuuxVsrRid8hHTNW3hZ
         qzLjy/jREsnO9Z5/fIaam342ddijzN/xzWGdU07YLOl4NlNVoG8I/a61E9lGqykZPIZq
         o9v843Ab9iZP/HdOZzH3ZDqgiQUgyON+cD/W+MhVrUWYYt6wgSzMpFdy7fc2aGaRkFop
         3paQucTJqz1Mkw3ZIvllNfQwXaPy4NbkxCUxCGUI3Bi/qK5+0LNzQo/jNWCPmM6Sm+Lq
         A+Kw==
X-Gm-Message-State: APjAAAXx563e7W64GTWyD0GLMnMXVooNOAxVCrZGgPKO3Lw0C9btRX6K
	iYUuKbTEnHOJe7+vu5YQmC4lCD5iEo+sUW68bMh+qAaRS09U9j3nPqzSe6c+kgU2MGIN0Wt9sSl
	aKPIHZmxt5La5o3vA9Oc4Hh8UcMmqKURkMcdZ9XrDrJQU8+cWl0HtDSIMpJ4ZPxaz5w==
X-Received: by 2002:a65:4bcc:: with SMTP id p12mr4611998pgr.187.1553042957740;
        Tue, 19 Mar 2019 17:49:17 -0700 (PDT)
X-Received: by 2002:a65:4bcc:: with SMTP id p12mr4611951pgr.187.1553042956849;
        Tue, 19 Mar 2019 17:49:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553042956; cv=none;
        d=google.com; s=arc-20160816;
        b=IDEplxeqx37fKddDHxNUANtl2AIOr9plLkcPyPCH1CX71xMpOTXD0ZvttqvFtV5xqw
         0Yq/Y6tXDq6bVA01eUp+fWQhOQLSyxc+GSPNI6/BWvgcUBSrpLosWX3zwJdrKQidcZ7P
         asNqM2V3Cvkz9SsUNJQOy7q70MTZxSyXdC5pssBiVrCSExZBXHR2/+lWBYPT+idCtyw9
         Zee8JUsOOgxumQAc8F8UyBBLeWTJfgVxV1wUS9ApKiPzbFulNd5tlS8xof0Ze/8Cu8Js
         3zVyUoZoWoN7xKUplcmyhyEZuW9/yg95YszkNaz3/4TbubmsjuXjUF8S/LjpWSRCX4+O
         Er7A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=woHC6P4IWHeqMPl0bBWCL/dn49O6TQqdOp+Q3BiQuPY=;
        b=WyEwVa9Uda9qAn8+6vZesu3XoWyAZNuSGEPFkN1ocYT7L7/iEIBgLbEIcMwuwga7Gq
         y5yrOYpIIcfy05DetadlKvl7J1q3o02V8s5hnfLrwB7Xsp3/2BSz389xpK3j8g2vsZjE
         f+kVpcs81hZ5BqbMJHemYj6fz+4Sb3TZvfNsyXS2xlWfL23UQIQ2D4vVgsGx5x5dwIiw
         onZM9y+u1n0u28e+1YVovtWq2q9VSRK34x4CPM8tz6iExVlLr5uAokT/xPdzBFqgxWFR
         kGy7SJUZbkvni3s05NM0tpPkqd9ofYBg1ET2p2YiuB8U4p5GkguP00JAxQNCvruM9YDM
         HyaA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=uQAnIj3z;
       spf=pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rientjes@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w7sor811460plz.53.2019.03.19.17.49.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Mar 2019 17:49:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=uQAnIj3z;
       spf=pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rientjes@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=woHC6P4IWHeqMPl0bBWCL/dn49O6TQqdOp+Q3BiQuPY=;
        b=uQAnIj3za4wrrwn7MJzIR0I98MQQmbfVD3GTktU1sIuzy5cmsKWcdvzDQC4X6+rvH8
         w6u3rtLEP3oq281/rdAsfnHNFTiEDCD5Sq/aJeDMIBS8t3a6+grQhuDmmBMk4JHa3+/k
         vq109n8sn+nAr2NyC3hsMZ+mU8VNNF7BEmW4jvJ89MlAHHM46CkcB5DqEGtK12AxOjVO
         4K0U+0pKhoX0dyV4I9HW97CCS2DdyN6mtY+USRwB529UqmXR3VHrgbratA6CuBBPSImx
         GSfAWkTfQlWwzTArpKAOkbTyMSllPqqThJxy7nPNbDUOsu4BQtT9rDdopXMu1e/mjCSK
         mYYw==
X-Google-Smtp-Source: APXvYqzU9Et7B/EaHRkr6v8Rip9mhd6P1ZraR9Jxn1pAooOpa+WFbT96w8mMoXRsA/HzvaCyFOLoog==
X-Received: by 2002:a17:902:ea8c:: with SMTP id cv12mr5255204plb.123.1553042956167;
        Tue, 19 Mar 2019 17:49:16 -0700 (PDT)
Received: from [2620:15c:17:3:3a5:23a7:5e32:4598] ([2620:15c:17:3:3a5:23a7:5e32:4598])
        by smtp.gmail.com with ESMTPSA id e1sm297905pfn.73.2019.03.19.17.49.15
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Mar 2019 17:49:15 -0700 (PDT)
Date: Tue, 19 Mar 2019 17:49:14 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
X-X-Sender: rientjes@chino.kir.corp.google.com
To: Yang Shi <yang.shi@linux.alibaba.com>
cc: chrubis@suse.cz, vbabka@suse.cz, kirill@shutemov.name, osalvador@suse.de, 
    akpm@linux-foundation.org, stable@vger.kernel.org, linux-mm@kvack.org, 
    linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm: mempolicy: make mbind() return -EIO when MPOL_MF_STRICT
 is specified
In-Reply-To: <1553020556-38583-1-git-send-email-yang.shi@linux.alibaba.com>
Message-ID: <alpine.DEB.2.21.1903191748090.18028@chino.kir.corp.google.com>
References: <1553020556-38583-1-git-send-email-yang.shi@linux.alibaba.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 20 Mar 2019, Yang Shi wrote:

> When MPOL_MF_STRICT was specified and an existing page was already
> on a node that does not follow the policy, mbind() should return -EIO.
> But commit 6f4576e3687b ("mempolicy: apply page table walker on
> queue_pages_range()") broke the rule.
> 
> And, commit c8633798497c ("mm: mempolicy: mbind and migrate_pages
> support thp migration") didn't return the correct value for THP mbind()
> too.
> 
> If MPOL_MF_STRICT is set, ignore vma_migratable() to make sure it reaches
> queue_pages_to_pte_range() or queue_pages_pmd() to check if an existing
> page was already on a node that does not follow the policy.  And,
> non-migratable vma may be used, return -EIO too if MPOL_MF_MOVE or
> MPOL_MF_MOVE_ALL was specified.
> 
> Tested with https://github.com/metan-ucw/ltp/blob/master/testcases/kernel/syscalls/mbind/mbind02.c
> 
> Fixes: 6f4576e3687b ("mempolicy: apply page table walker on queue_pages_range()")
> Reported-by: Cyril Hrubis <chrubis@suse.cz>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: stable@vger.kernel.org
> Suggested-by: Kirill A. Shutemov <kirill@shutemov.name>
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
> Signed-off-by: Oscar Salvador <osalvador@suse.de>

Acked-by: David Rientjes <rientjes@google.com>

Thanks.  I think this needs stable for 4.0+, can you confirm?

