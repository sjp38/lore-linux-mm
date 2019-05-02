Return-Path: <SRS0=Mdb/=TC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8A959C04AA9
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 13:04:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 538C62063F
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 13:04:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 538C62063F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CB5366B0008; Thu,  2 May 2019 09:04:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C3DB96B000A; Thu,  2 May 2019 09:04:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B05A26B000C; Thu,  2 May 2019 09:04:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 779866B0008
	for <linux-mm@kvack.org>; Thu,  2 May 2019 09:04:24 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id 141so1745679wma.3
        for <linux-mm@kvack.org>; Thu, 02 May 2019 06:04:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=CFT7t0IeuMz3cc6eysZRpfWQofkdL9up1l9Jh7hd2Ug=;
        b=HaIynMoEmMAlHsRDKTk/34xzqL02tFgYnmbfiDnN0IULyVU1Rh2srj1tv3RanG52lt
         OxNyCK+kEGcM7r4JiHhz8R7EUPZnNOIt0EXEbhqJeJrsPIJ3KdzgJ7KfEUaXDzurHycd
         zwJmfDk7QmzaOuzNwKMWNyJt7+ep4hhxlexIPEU7Wlh65Xdakx0lhYuX5MQyBaeraOPX
         SMxI7IqK8bzRH+hDEXxzNU+QTmB1amJ1tdzAHdmKfXjk5gWc/edgmeutmFBKduCTJ9Sm
         3OvtQjPR32MwldT0bIJvxczQAtdI2NzmKzck62Dkk9wzAwn5vIHHOcFi7KJCOURylzuE
         BJWw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAWyVjFevp85s4yHK7se89dPAHjLfl7Mwa+1daapasICsls8Mh/n
	wn43zLAKrgAyOhABq63UXSCu1HSTTmjbaxEmUaWeVPiQGV4Q3y+e1m1v94IpxWslAoEiCeNEgyd
	5W493R2K4MIU11t5SFxTGW1HDa+OG8U+pQCGIH71c8vZR2HI3XVnthGhfDI/IkUvKlg==
X-Received: by 2002:a1c:c004:: with SMTP id q4mr2150270wmf.131.1556802263953;
        Thu, 02 May 2019 06:04:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqweaAy0iyMNGMyldzO+gBG+V1GnucTbdKJ/pksexThB8J9eiD+85eRgMGEf7b+byhbg6pFw
X-Received: by 2002:a1c:c004:: with SMTP id q4mr2150191wmf.131.1556802262586;
        Thu, 02 May 2019 06:04:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556802262; cv=none;
        d=google.com; s=arc-20160816;
        b=k6SCj02raqZ0YvpiqvdtznLBUdPQ/jVd9/HnXqRjEyP42vyRKUUHJptnVP/dSlmrW5
         iWYMJF5LPfYlMC4DRqdIwQTL2IpBuNHRs2Y8c8x6RbR1NH1hdG26RstCwsIF4aeScmr+
         eFTlLnXoGAgFDBGp+/iJbrb/io8E6MaPDmLMgJLuIoT/3okV9EGk2pwg8KUmyBaNsWRM
         87sb4xn9TAGXR4S3H/z3uBeCXvD91PzLANYEmS+StKpZafjMLxjJiOuGB8bLCmg8+W1k
         f7OveLJ5241SiBq+xVLDnlRnw0lSx83n+RU8eaaMbOlBKwonreWxvR+FTJBZVKZNKDhe
         5hgQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=CFT7t0IeuMz3cc6eysZRpfWQofkdL9up1l9Jh7hd2Ug=;
        b=k92HL/CeKHZoa/YPkWCXVpatG3sKqIsFQ+lTvSTPvr6grsL3JJOBpRWVkKKI5X1rOH
         PO9UmIwQjZTwfaB4+B8c+zhS3QoUwAEK32tsZ+TiQ0+GB+esNujFXggo0Q0bM08UV5qn
         2NZDC0eVswf78SmEMSw9KlOMpLCudXKI/baX+jvQGQEdzJb5n2GhuMyoUwGcrJwZYAWD
         wM5UdcnNNclNpyFEyz7EhYd+ni/r0zTvrtYd1lZz/N+cNNtWqdJeOjie6gBk2pNISA12
         LUd3wkpNjMeVwnepD0G2qUlFr27Yohf9R+xJ/O+OQuoYd5dAvHpztz6ynNpyT1xdYUvs
         dV+w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id n1si4527234wrm.328.2019.05.02.06.04.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 May 2019 06:04:22 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id B32F368AFE; Thu,  2 May 2019 15:04:05 +0200 (CEST)
Date: Thu, 2 May 2019 15:04:05 +0200
From: Christoph Hellwig <hch@lst.de>
To: William Kucharski <william.kucharski@oracle.com>
Cc: Christoph Hellwig <hch@lst.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Sami Tolvanen <samitolvanen@google.com>,
	Kees Cook <keescook@chromium.org>,
	Nick Desaulniers <ndesaulniers@google.com>,
	linux-mtd@lists.infradead.org, linux-nfs@vger.kernel.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 5/4] 9p: pass the correct prototype to read_cache_page
Message-ID: <20190502130405.GA2679@lst.de>
References: <20190501160636.30841-1-hch@lst.de> <20190501173443.GA19969@lst.de> <AEBFD2FC-F94A-4E5B-8E1C-76380DDEB46E@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AEBFD2FC-F94A-4E5B-8E1C-76380DDEB46E@oracle.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 02, 2019 at 12:08:29AM -0600, William Kucharski wrote:
> 1) You need to pass "filp" rather than "filp->private_data" to read_cache_pages()
> in v9fs_fid_readpage().

With this patch v9fs_fid_readpage takes a void pointer that must be
a FID, and we pass the FID everywhere:

 - v9fs_vfs_readpage passes filp->private_data
 - v9fs_vfs_readpages passes filp->private_data through
   read_cache_pages
 - v9fs_write_begin passes the local fid variable


> 
> The patched code passes "filp->private_data" as the "data" parameter to
> read_cache_pages(), which would generate a call to:
> 
>     filler(data, page)
> 
> which would become a call to:
> 
> static int v9fs_vfs_readpage(struct file *filp, struct page *page)
> {	
>         return v9fs_fid_readpage(filp->private_data, page);
> }

Except that we don't pass v9fs_vfs_readpage as the filler any more,
we now pass v9fs_fid_readpage.

