Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 32C61C433FF
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 06:48:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CC3B02073F
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 06:48:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CC3B02073F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 62F4F8E0003; Mon, 29 Jul 2019 02:48:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5DECD8E0002; Mon, 29 Jul 2019 02:48:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4F4788E0003; Mon, 29 Jul 2019 02:48:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1C32D8E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 02:48:47 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id d65so13390464wmd.3
        for <linux-mm@kvack.org>; Sun, 28 Jul 2019 23:48:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Mpd/f2UHbkmNPwjBzNy0B1fPlV33JHH7cu3Mr80hg4Y=;
        b=AXDh9srFFQ4Nh33H37bB38GQ8lQV75zYl1Yi6Pjn8sB2qlM1V0tU/rmyVMjH+e0IRT
         3LO5OMZgey/NbAhYTZfusCMEG8V6IhQraG8tqLWNSKrflHA+UBdYV/4vG5wVWWQPwhE0
         cK/APYsvHyvhf/xEIWKJ52j37reKktBZatsb51LdmuQ3oqizS1e3HtpwlveK960laBkB
         aW8IphM4/fdL2yTcuPRZmiWYOK50QKlMcZeZzJ9rqrgvASMnBUm8TajWKGqgzz5xq1Kb
         61jcrfu7OTfqjFw6ufocIvJ/h8PgE7wd5BFnQIju8/apugxTQkMhjca9Zvjl1EOMwf8i
         7AWg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAXyc3CDZa01Ulr8pZo7wDpk4j7kAsvo3pxhWz4ZKbenHX3ejwvc
	oGEoWSgR8JEWeSZMH9g1ECc95yjJzX3qjZuIuq+lBLVAso9PZNFNYiNLP3N8lqmhutyl9qiK9TV
	eiX0ZdOCkuAgWqA6NCsjYCOFK8F15sJqjhzDkysU/3iMYLmUUNliua5OPc63D3vv0eQ==
X-Received: by 2002:adf:ea88:: with SMTP id s8mr110000024wrm.68.1564382926726;
        Sun, 28 Jul 2019 23:48:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxqogsjCCyu3vx7QRZrU6RdyvQ3STngPQ/xXK7eA8ofrrFAa62+M4gWniUDGUQHFfUEyeoe
X-Received: by 2002:adf:ea88:: with SMTP id s8mr109999924wrm.68.1564382925930;
        Sun, 28 Jul 2019 23:48:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564382925; cv=none;
        d=google.com; s=arc-20160816;
        b=KuD6I52cors/KN/3dQmVBJLGec/KELolvlEJK9/yYA9Uuhm5qosNUGsPLX40PDQ+h6
         W7Wdoo2jvkfPLyUBpPGh7iz5286d3rlfSGHb8VkU+eOadBaulIjQLDNTJTMlhdZmpgPh
         i8+zK/NRxkQrt2Xaex3KtTUXGAyohwx4zefSbTN5QbhBGQjx/JPJZ3x6VrreHHJvOlBU
         yBy70M9/63a4sdSMTPoGWWI/m5dDFwJp3RhkWoF0dp0+fKW58uRYgn17QhtteHkClXR7
         UWF7Uoe8UvrflDkoSUK/CkX0lULRHePMRfKGf22xcVGImmI9/S+b94qFyOOIXjy7XLkk
         Jgng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Mpd/f2UHbkmNPwjBzNy0B1fPlV33JHH7cu3Mr80hg4Y=;
        b=gCD1+WFQZo/El0UH75iMuidTXPkIyEmRV7pj2hqvbc22L26g7K4GNtZij5cDFTNbVq
         +SdWFOiyMf+HKNTzyF0iS2vmyMFhwRA47PrykhY6e74YJOYJzX2rWqu5TP/KBTiEBycD
         dzfsFTcbs93cetlU4n+ZAI+TP8H2NQPpHRFC1phcXxJwVBmaSM3SbwSSIhBxENh9jrYR
         Nms0nc1UVGhkXXjJwQ57J6LNHerD3BQ7bCMNGphyy2Y0zZoesQ8Td8GN3RgYopgSmdMo
         rVTdDQ8ravmOYckwzBYUOzG/l51InX2E4nyOjsZ5iQ/NP6qkJiAnPvoFAE15rIdGYFI6
         AKqw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from verein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id m9si46179288wmg.153.2019.07.28.23.48.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 28 Jul 2019 23:48:45 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 03FB168B02; Mon, 29 Jul 2019 08:48:42 +0200 (CEST)
Date: Mon, 29 Jul 2019 08:48:42 +0200
From: Christoph Hellwig <hch@lst.de>
To: Bharath Vedartham <linux.bhar@gmail.com>
Cc: sivanich@sgi.com, arnd@arndb.de, ira.weiny@intel.com,
	jhubbard@nvidia.com, jglisse@redhat.com, gregkh@linuxfoundation.org,
	william.kucharski@oracle.com, hch@lst.de,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH v3 1/1] sgi-gru: Remove *pte_lookup functions
Message-ID: <20190729064842.GA3853@lst.de>
References: <1564170120-11882-1-git-send-email-linux.bhar@gmail.com> <1564170120-11882-2-git-send-email-linux.bhar@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1564170120-11882-2-git-send-email-linux.bhar@gmail.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Jul 27, 2019 at 01:12:00AM +0530, Bharath Vedartham wrote:
> +		ret = get_user_pages_fast(vaddr, 1, write, &page);

I think you want to pass "write ? FOLL_WRITE : 0" here, as
get_user_pages_fast takes a gup_flags argument, not a boolean
write flag.

