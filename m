Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 805F1C31E5B
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 21:15:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2C054204FD
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 21:15:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="RMyro6uQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2C054204FD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C926B6B0003; Tue, 18 Jun 2019 17:15:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C43B28E0002; Tue, 18 Jun 2019 17:15:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B31A98E0001; Tue, 18 Jun 2019 17:15:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7C4856B0003
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 17:15:23 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id y5so10109758pfb.20
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 14:15:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=y0FYGQJW9l3L3zb3toiL7Z69S/obMAXLWT2LzgwCA5k=;
        b=VCq60Yjqqs+18jZsIC35JUe3Os16ZK+ISIOXn45LHBNrccW42viTg1HTA/Ky4obj+N
         +WEan2o33O6W8prQmxd00n9tl9DSatZZ6hD/dJPsawBt9yho5FqU6VajAOOHSK7ZzIDP
         VOPbiWH1rmu4dkoP9oNRFMsVdMA4pSxD9hglr6pCuqKzKWtgSgKTrq+poWyrd8P+GXHH
         5TQKoZCIQpxEtowHUlIxT0E4tqb57m4p4kVX8arwZzBKPcZmYADjQNR3iqXcG3XKeXCC
         st3lE6+JAxTMmTPaDPl6Ogs2BmKNtKl8xUT8Qpkf9EnIZ7pBr2N5pdlZnUyvRYPKgYNj
         h7Bw==
X-Gm-Message-State: APjAAAW+Jw2eMqPZSda7dM5R8eZxZYYpXvxgCnOBuXD903T5bis32SX5
	tolP6X4Ufbakw3Wxd833Bb+r3Qd5AHqqD2L4keK6NRbNomjeUuYXAib5403KDcuT1yAYUO9HK3h
	fjpAu0/gkdCdCb13U57wV8swlH9ysCtwKwmtSl1hckSQZqXnNF2YvE8Yom+5j+bhQKQ==
X-Received: by 2002:aa7:934f:: with SMTP id 15mr41802541pfn.238.1560892523048;
        Tue, 18 Jun 2019 14:15:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwWQH8EsG/FxZm5y3vNDTW27hKSUXm5Aq1mZIv6/UdryDcV7CZrZIoBRwB8e5+oY/xxo3pK
X-Received: by 2002:aa7:934f:: with SMTP id 15mr41790109pfn.238.1560892344667;
        Tue, 18 Jun 2019 14:12:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560892344; cv=none;
        d=google.com; s=arc-20160816;
        b=PNDAteR/frtNVV3P3IdLju2bwnQAWyeT/Cv7QlsJDvCsfOTLZbCh3ARRQbOJJqwhBx
         gvAyKd5bcykJEQ8I8iRh4fqs5kEuFNPnFjst490qZLWMUIJQt/wNKUheXA+/CVKJzLlY
         ns7qiz36BZrf+xdnqdmcXyfCyNm33WawtkPXjPGjJrjvdYXNRMIWyIQDodkspk1L4Q50
         Vn9mLeXSG23cymnafDCQhTahSm6HD8Oy0O0lJ6fSC6xww9OXzmPZZeKlHY6/ACP25KtP
         Ojg9voqNRa4Jb387ql40m2Eaod+uXrN6RQqBaWQEN1wICAb4JwrLg68lXNZK8sMDmUIt
         o6Rg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=y0FYGQJW9l3L3zb3toiL7Z69S/obMAXLWT2LzgwCA5k=;
        b=XlD9l+bFhmQSm9FzLVyC1y0LnI+WjrqM9e5ilCt6jdUjKyFk3gKuMeB9NorR/ODxjZ
         pinSLI7Kf3SpwCLUYY13bHI56rdlwKybfSrpBPmHtBbHAJxOK+qdtP6RdxGOmbGtmp4x
         UJywmvhxN5H1GdOqlX+VsbTacgP4IYtt6u3veY0+pNA7HkZi8suvltlTpdKg6343JgWL
         o8tyA03xfh3/JAgtvLAkuWzhHfj+0R7bI1GWBRneZTjxPF+4pup7KwcwPOUvf3zRFIfH
         fob2lSxQHqbI16UHPRflt7k3F9ejFVIfqG3ByCBC1O7bfgQblXhCxTNegGnLfXAd+IkP
         n6iQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=RMyro6uQ;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id f59si14802805plf.220.2019.06.18.14.12.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jun 2019 14:12:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=RMyro6uQ;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 0D528204FD;
	Tue, 18 Jun 2019 21:12:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1560892344;
	bh=iIcWIP63goW0n8A1BUOEFoZNNlAyCWB2IcaUcVIUQbQ=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=RMyro6uQGloBw14KTG60tbBSjWQuoQCde7e29DfCpnESOu7gIBPhCwjPoTHMAWjAz
	 zlkeZmNx5XBmY2csEkW/Q6cN4eb4EeBsiSxZwFJvxTCVu1jz9QpMMshdkLrSaI3zsk
	 EtXXXBjQrHgdxcHvtZ8pw6+0rkXbsM5MLmNeMvOk=
Date: Tue, 18 Jun 2019 14:12:23 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Song Liu <songliubraving@fb.com>
Cc: <linux-mm@kvack.org>, <matthew.wilcox@oracle.com>,
 <kirill.shutemov@linux.intel.com>, <kernel-team@fb.com>,
 <william.kucharski@oracle.com>, <chad.mynhier@oracle.com>,
 <mike.kravetz@oracle.com>
Subject: Re: [PATCH v2 0/3] Enable THP for text section of non-shmem files
Message-Id: <20190618141223.4479989e18b1e1ea942b0e42@linux-foundation.org>
In-Reply-To: <20190614182204.2673660-1-songliubraving@fb.com>
References: <20190614182204.2673660-1-songliubraving@fb.com>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 14 Jun 2019 11:22:01 -0700 Song Liu <songliubraving@fb.com> wrote:

> This set follows up discussion at LSF/MM 2019. The motivation is to put
> text section of an application in THP, and thus reduces iTLB miss rate and
> improves performance. Both Facebook and Oracle showed strong interests to
> this feature.
> 
> To make reviews easier, this set aims a mininal valid product. Current
> version of the work does not have any changes to file system specific
> code. This comes with some limitations (discussed later).
> 
> This set enables an application to "hugify" its text section by simply
> running something like:
> 
>           madvise(0x600000, 0x80000, MADV_HUGEPAGE);
> 
> Before this call, the /proc/<pid>/maps looks like:
> 
>     00400000-074d0000 r-xp 00000000 00:27 2006927     app
> 
> After this call, part of the text section is split out and mapped to THP:
> 
>     00400000-00425000 r-xp 00000000 00:27 2006927     app
>     00600000-00e00000 r-xp 00200000 00:27 2006927     app   <<< on THP
>     00e00000-074d0000 r-xp 00a00000 00:27 2006927     app
> 
> Limitations:
> 
> 1. This only works for text section (vma with VM_DENYWRITE).
> 2. Once the application put its own pages in THP, the file is read only.
>    open(file, O_WRITE) will fail with -ETXTBSY. To modify/update the file,
>    it must be removed first.

Removed?  Even if the original mmap/madvise has gone away?  hm.

I'm wondering if this limitation can be abused in some fashion: mmap a
file to which you have read permissions, run madvise(MADV_HUGEPAGE) and
thus prevent the file's owner from being able to modify the file?  Or
something like that.  What are the issues and protections here?


