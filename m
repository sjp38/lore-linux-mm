Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 12B71C76188
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 09:37:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DA1CF222FA
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 09:37:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DA1CF222FA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 722886B000A; Mon, 22 Jul 2019 05:37:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6AC2C8E0001; Mon, 22 Jul 2019 05:37:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 54C9E6B0266; Mon, 22 Jul 2019 05:37:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1EE9D6B000A
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 05:37:47 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id a5so11039452wrt.3
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 02:37:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=+CWVkUyTGr6WkeMM9IIFyHjdWCbd0nKCZ4Isp+2vuqk=;
        b=gleHA9oAq6NnrXHKiTgk4CxHP4IigPVqM+2VibGAn9uKiKKP8WBFQT9yIMZxZppr0N
         Qtl5lgrjcG55SpgddU1ziF39h2+IEtBSCHbRMByPkHc0sGd/Nja5cm3/F/nTDBcmtqvH
         lhBqEHMAKQc6tEzt0+2pylqmdK9e/svn0hCs4t9GFQVkTR9qqbhHSNTLbVR3F+WqxdRW
         FobJT0lalrIcJtuG3nQ0z+NxGvhj+AYJQkR6ZfyEHMQptm/qJXxG+7yp6cbrioc7U/nF
         lMOyv0VbvWHvAAzcwSPAX8wr7D+CGCziqGUhp6bZsxo+5ImgzmuBP9O5Q/3uuDBde3FE
         Xeog==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAWoftv/UJMHklxFN27s7vwPNS+xfRMTFUDh/80wxwUhjLcBDOe1
	S0/posZJFkwJM+CbTB/BOY4SpkEMSUpVrXaUnT6gOjVLo2b+WGpMuRgtCBDevcW7ph6pLpr/FO2
	eCm390LzCXDFlAHeHNso8XyZPmeaI+EVs2yMye4RSAklJYCWDTdYLR9p6D6ZtXEKBwg==
X-Received: by 2002:a05:600c:206:: with SMTP id 6mr37578119wmi.91.1563788266669;
        Mon, 22 Jul 2019 02:37:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxp4fiGugn4evvISzxS6wIHU26WQxzhsUvi+13ZSCjBBb7QuxvW8/hyFRHF/3ikgtWoPElf
X-Received: by 2002:a05:600c:206:: with SMTP id 6mr37578007wmi.91.1563788264543;
        Mon, 22 Jul 2019 02:37:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563788264; cv=none;
        d=google.com; s=arc-20160816;
        b=BCbOjto1bXx+TiBefD2IFrAKlzRBUk6n61Zqs51yQCOW7cUAqDUP4wfz0IQrv8g9P6
         QmxsCCI7Z8Y2nWNMwmMQAHaiznurerkgRDB13cl7mnmEeGDx9aqPXdwvDjt6JLtadcHT
         yNk89xBIGkhfl0WJ22trqWpPn5QMzaJmL9xe6NLyFZWtbVIex/7LYsSAa4S7BB//gV6x
         Wqx4ZXMnXMryEx9XK8IkH4aZhsBFj0nQEtnX/rpXrIrUkNjQZHAoP8l3e/UL4m9r+BNt
         8BzWljpQGIKNJiZPWJnoHb95HSXbQdeH842BgoXp9c0ZiN9uTTqsyx+DY2WY/uL2BYhD
         oCAA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=+CWVkUyTGr6WkeMM9IIFyHjdWCbd0nKCZ4Isp+2vuqk=;
        b=go54UguEm1VaikGnc0AJ+ubDrQwck+WBz5e5sW+eVdxkB7akbC6m8INgOXCjtkgGJd
         ZbUxV3qKZsPirIGQDjCAWwNlSjZDcWxKDIC7TMxu6IsR4721Ygw7kKUQYTNxzz12tWZ+
         JdaC4W0WREpWXPNcBE4rZZk2lmCBKp4yb/dHBI7jruEyXsGB4+s+DEnCBRGL6VCx7p6k
         D8YiTm1Zj5MJk6UtjEXrMgJSKjGiLOh9p9VNziXD+hba6oGLaUgnXn9+u40Zm5nzJ6bM
         4ZOtbkxJmLV3satsi+sdKCbDN5Zt2gpFt+T1JSq4NLKkYRs9HI/TkeMHle7W4QHP/1+W
         i6uA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from verein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id c6si39566154wre.296.2019.07.22.02.37.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jul 2019 02:37:44 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 1B95768B20; Mon, 22 Jul 2019 11:37:44 +0200 (CEST)
Date: Mon, 22 Jul 2019 11:37:43 +0200
From: Christoph Hellwig <hch@lst.de>
To: Ralph Campbell <rcampbell@nvidia.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	John Hubbard <jhubbard@nvidia.com>,
	Matthew Wilcox <willy@infradead.org>,
	Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@linux.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Lai Jiangshan <jiangshanlai@gmail.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Pekka Enberg <penberg@kernel.org>,
	Randy Dunlap <rdunlap@infradead.org>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Christoph Hellwig <hch@lst.de>, Jason Gunthorpe <jgg@mellanox.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH v2 1/3] mm: document zone device struct page field usage
Message-ID: <20190722093743.GE29538@lst.de>
References: <20190719192955.30462-1-rcampbell@nvidia.com> <20190719192955.30462-2-rcampbell@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190719192955.30462-2-rcampbell@nvidia.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Looks good modulo any potential kerneldoc issues for which I'm not
the expert:

Reviewed-by: Christoph Hellwig <hch@lst.de>

