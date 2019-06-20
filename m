Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4B62AC43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 01:13:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 087A6208CB
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 01:13:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="lB8ZahE3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 087A6208CB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 86A256B0003; Wed, 19 Jun 2019 21:13:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 81C1F8E0002; Wed, 19 Jun 2019 21:13:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 70A578E0001; Wed, 19 Jun 2019 21:13:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3C2D66B0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 21:13:57 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id c18so621556pgk.2
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 18:13:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=w0TfWjjGxZXnNLe75uqW4x7wWysv+Q1+ApptO7F03Yw=;
        b=IvTZN0BpvZ2PQE3tERA/4Sd3Kq8CQ7Zne/IRlrwxb0FCeyElGmDKPW6H7sZC7DLaqw
         ksTrGCVo2GOb0/LKA+qeoh4nBKvyCrT+I0otU8Tb+Z5mZ1tx/Slm9YsFB62Kj/Q7On98
         nQWRtr/Sl9dIWmkL5CrHUZZPCjrZngytNDHEV5dUrxk9UoHy3DBKlCPTTnutAAvJTEbf
         jzMHUYQUWeoFK5X5YCmSsIDuhySk+QCszfYRpN2BvlUF97znXgh09i/HhRba/L+E3TP1
         MCGqlVWp3MMLUKXaGDvEwmECnb8JAeqhfxz/DSxjYJpEJWG5LnPlxhp+bgjoVrMnQUpI
         oNhw==
X-Gm-Message-State: APjAAAWy7U2pG281hn1OCgk276SPa2e2EowLAMyDIUUkIfuZ1CHzCvWX
	rUA+FKlpAi8wuE4aSqBz7CyhMmBGYrvnbnQDlrpkmEiZ+UctUe3KkjGVwq9VwGPG5f81CTZ6H3h
	JWi0j7kIZ/Vtu2V1eE83jpBEle0QkowN9JZhFaD3rjire3x/gHINdoRGZrop8ySS7Vg==
X-Received: by 2002:aa7:8281:: with SMTP id s1mr23241533pfm.156.1560993236735;
        Wed, 19 Jun 2019 18:13:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzsZ52ewdggyi8fNdP0cU81szJk/2H/cP+dnbyl9e8WCtG2lk+LUBwtZygdtj3NXmogU9Po
X-Received: by 2002:aa7:8281:: with SMTP id s1mr23241489pfm.156.1560993235956;
        Wed, 19 Jun 2019 18:13:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560993235; cv=none;
        d=google.com; s=arc-20160816;
        b=yYmHPLOrEFriP0J929hKOnrr60rK2M3C7nPlhJJtSFznsNp2QM+GKuDiKIUZ2za3Jc
         p1EGTLOOgutXuqfcXoSWQjlJHb/fvHm5+oPw8XsYtNa5JIYvM8H4l4fda1t7hnxOhunI
         Hl9fooZcC5z85LUwKQ9XMZAT66zF3wN4lvk5Qln9gEvRPB88ItjLtc1gGwFQyvsNGn/J
         YbZ/8mXAYHI+oJhdAxgZxZNzyuMQT7N7tsxo0QvkOsqyrOdTm+izhJp2hw9yQcgjH81z
         F+gsrAmoM+at8NCy6JJr93pN1IfCXYkt7SjvOpt6S/82YVpLDMTJGThkr+SLzPwjedrC
         gFYQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=w0TfWjjGxZXnNLe75uqW4x7wWysv+Q1+ApptO7F03Yw=;
        b=kwbwtBH0BmIttCu2oZG+pHx5yVoYByQPqMY7XQH3uLbrw3Sf7WmCCuERGdFfIJIJEg
         xwQMhJv66TjkH8PoLoAaE8J/vWUwAFNo6x6W1jfvy7uBdwI2oNnuu/uLah/x2XRLKe8H
         EiCet94Y3QkXZWljdDtyjUHnbU6i0txY7QsiytygM/xigOxAyK2/OzTBtknOw1olEKLU
         5I/xoqYKQq8omirTy6d3bikFA4ch8vYg1T0H0PGBR8mGFRdJAlvPi2qnnMvf9U6K8aYV
         rzBQdbPb91nx4EneS8eLgVcSPZD15Fb5QRdx+uz2Gol4K8oaWqbqsvg9WJ6SN+EZ5/+G
         m2yw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=lB8ZahE3;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id u1si17630176plb.234.2019.06.19.18.13.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 18:13:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=lB8ZahE3;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 4DD0921537;
	Thu, 20 Jun 2019 01:13:55 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1560993235;
	bh=P59+R22oGjQzQ5UazJQ6goAF+kG6jrHGon1BRunWZI8=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=lB8ZahE3kR8MRuqYoLNv6BJZwFHxbc69TjEmXUelsPBFeXDYDMqaN50PEk444AVV9
	 oaQj8r90biFPn7ckXT5WTlJHeSrQnr+GIZvOxB4JofbrI3W38nKRepKwMQww3Rhvsc
	 srdkwWjuvcxk2cXEsbwCZ79tM+b4+vlEp/G1eeDg=
Date: Wed, 19 Jun 2019 18:13:54 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Song Liu <songliubraving@fb.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "matthew.wilcox@oracle.com"
 <matthew.wilcox@oracle.com>, "kirill.shutemov@linux.intel.com"
 <kirill.shutemov@linux.intel.com>, Kernel Team <Kernel-team@fb.com>,
 "william.kucharski@oracle.com" <william.kucharski@oracle.com>,
 "chad.mynhier@oracle.com" <chad.mynhier@oracle.com>,
 "mike.kravetz@oracle.com" <mike.kravetz@oracle.com>
Subject: Re: [PATCH v2 0/3] Enable THP for text section of non-shmem files
Message-Id: <20190619181354.325242c09d5c2ef44f430b4a@linux-foundation.org>
In-Reply-To: <BA4D64DA-4F48-4683-8512-0402B9533EE7@fb.com>
References: <20190614182204.2673660-1-songliubraving@fb.com>
	<20190618141223.4479989e18b1e1ea942b0e42@linux-foundation.org>
	<BA4D64DA-4F48-4683-8512-0402B9533EE7@fb.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 18 Jun 2019 21:48:16 +0000 Song Liu <songliubraving@fb.com> wrote:

> > I'm wondering if this limitation can be abused in some fashion: mmap a
> > file to which you have read permissions, run madvise(MADV_HUGEPAGE) and
> > thus prevent the file's owner from being able to modify the file?  Or
> > something like that.  What are the issues and protections here?
> 
> In this case, the owner need to make a copy of the file, and then remove 
> and update the original file. 
> 
> In this version, we want either split huge page on writes, or fail the 
> write when we cannot split. However, the huge page information is only 
> available at page level, and on the write path, page level information 
> is not available until write_begin(). So it is hard to stop writes at 
> earlier stage. Therefore, in this version, we leverage i_mmap_writable, 
> which is at address_space level. So it is easier to stop writes to the 
> file. 
> 
> This is a temporary behavior. And it is gated by the config. So I guess
> it is OK. It works well for our use cases though. Once we have better 
> write support, we can remove the limitation. 
> 
> If this is too weird, I am also open to suggestions. 

Well, it's more than weird?  This permits user A to deny service to
user B?  User A can, maliciously or accidentally, prevent user B from
modifying a file which user B has permission to modify?  Such as, umm,
/etc/hosts?

