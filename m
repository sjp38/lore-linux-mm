Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2FB21C48BD5
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 07:41:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E46FA2054F
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 07:41:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E46FA2054F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6C9816B0003; Tue, 25 Jun 2019 03:41:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 67BF88E0003; Tue, 25 Jun 2019 03:41:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 568E38E0002; Tue, 25 Jun 2019 03:41:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1E51D6B0003
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 03:41:41 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id v125so216643wme.5
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 00:41:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=YxEe+TfzYdoF7gXQHEX1rhAsD62x/1wz9ola/yzBcz0=;
        b=VuhLqzs2prhBmKWQgEO7BKSsTraTJjH9c+Qkq5vS8889tEbM8Y6AeHIZhPlxv+5yav
         +mqUbtLC5/iWDqjQ95sm664dn36HcGLoYc4ao5Z6z9ATAva4gXxjrRmpX7uiuNsxCVaN
         KxqyZsfYuY5to06jV1/uxdFYby9UFN2dh/DxgvvsHI8tdbsqv9N4EnmgL8dwIbKJJXtR
         Zc8cOiUclixwl51E1k0czITxDieKCgKDWaNUC27DBsHMohOAuWkQd9nZGTWhdrvk0wFR
         KVKHi+K1WXhL1pnlHWXYUEbOx5krbVs3zPEWlICcZV2OmrZHekmAV4OH8MzAf1CaP73U
         d0RA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAVkntecPWTNSFb/Yb818q3RuqNDoyXpIdfjToeH1JVQmF+Ibl8I
	6tqeYe+8w15as7jZEp6aPRwbZQgSIIyrqxcCNfT0iNVNf7A7EeGcYIFTvqc/84DD9RA9CC+swJi
	fnoX1PGlQ880A7rduayL7Om+5/lWpJPDdbCZxMl3fGahdHGCS89XQI/mtUuzAV/sq/w==
X-Received: by 2002:adf:f948:: with SMTP id q8mr15078775wrr.196.1561448500726;
        Tue, 25 Jun 2019 00:41:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyMi91whVNH3aIBk/FeYU/SfcgmsoY9SvwtefnHefBCI5QMrHqf5KY7SGqmWN+3oylsZAZw
X-Received: by 2002:adf:f948:: with SMTP id q8mr15078742wrr.196.1561448500106;
        Tue, 25 Jun 2019 00:41:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561448500; cv=none;
        d=google.com; s=arc-20160816;
        b=SUoGysbsoPc4VbOZ6jaPIzP3RoWuFCCUID+LDLPzvUG5DFsUGBrMxGRQxnRaQr0bvM
         uHrPOR4DqsWQe3zhvVpyf1ALvFg8nPsn7sq3dVJpYpyjGFeB5J1so5Cb4pFjxXgtmG01
         Jsb4astAA+x7mQNiVpxXEuX1R7LXWk7n6Ncav/hiYRP8tmaTiot+TamWzTolQv97SZX+
         1QZnWFOKhum4lvRVcRudY+1XOmBVHe3wPyuQCKeARypU5irXXvXKEbMLx+4SuW0Xvpex
         axY07PQA+WP4qBSscQyIDT5d63JRn1e1jEsld+XQasZn/18HzILZlaSZ7KFLDij5VDvf
         /M0g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=YxEe+TfzYdoF7gXQHEX1rhAsD62x/1wz9ola/yzBcz0=;
        b=NWekavTsOTLl99/zfD5PtoYVBXBvJFUk3U+Z3j2CAGArbHZQDmEtJxAC7meN4NnQHG
         p6JxlpVpUXigJaz5vguwh7DqQYhDMfFhSFQTgab7nAhl9SERitZL0KyZxFehT+9dZJvd
         D+aIEdO9Y33xg+Wq9q8hKgyM3rJrzweFW+RrMsn89DZh/a60P0c4ZGlCz5mMWV2FnJ0S
         2tYChSpU//UoFyj4CnmfQgl74W+DrwvF+qsAa/+6LMYcQhVvzzm3oZ/2y3Fjk/W/1teU
         l7DRpZqLojbXlmGatYi9XfYMVMFkNfmq/ZvDd2LmqXM3dpb+iBXOe6Imt6IjCXT61jQd
         UcBw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id j17si11908465wru.409.2019.06.25.00.41.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 00:41:40 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id C953568B02; Tue, 25 Jun 2019 09:41:08 +0200 (CEST)
Date: Tue, 25 Jun 2019 09:41:08 +0200
From: Christoph Hellwig <hch@lst.de>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Christoph Hellwig <hch@lst.de>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Paul Burton <paul.burton@mips.com>, James Hogan <jhogan@kernel.org>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Rich Felker <dalias@libc.org>,
	"David S. Miller" <davem@davemloft.net>,
	Nicholas Piggin <npiggin@gmail.com>,
	Khalid Aziz <khalid.aziz@oracle.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>, linux-mips@vger.kernel.org,
	linux-sh@vger.kernel.org, sparclinux@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 01/16] mm: use untagged_addr() for get_user_pages_fast
 addresses
Message-ID: <20190625074108.GB30815@lst.de>
References: <20190611144102.8848-1-hch@lst.de> <20190611144102.8848-2-hch@lst.de> <20190621133911.GL19891@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190621133911.GL19891@ziepe.ca>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 21, 2019 at 10:39:11AM -0300, Jason Gunthorpe wrote:
> 
> Hmm, this function, and the other, goes on to do:
> 
>         if (unlikely(!access_ok((void __user *)start, len)))
>                 return 0;
> 
> and I thought that access_ok takes in the tagged pointer?
> 
> How about re-order it a bit?

The patch doesn't really work as-as an misses the main
get_user_pages_fast fast path, but I'll add something equivalent.

