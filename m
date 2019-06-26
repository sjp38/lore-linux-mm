Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 65401C48BD3
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 23:15:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 28DDE2184C
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 23:15:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="uTJS3ibn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 28DDE2184C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B47036B0003; Wed, 26 Jun 2019 19:15:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AF6D88E0003; Wed, 26 Jun 2019 19:15:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A0C788E0002; Wed, 26 Jun 2019 19:15:40 -0400 (EDT)
X-Delivered-To: Linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6733C6B0003
	for <Linux-mm@kvack.org>; Wed, 26 Jun 2019 19:15:40 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id b24so232099plz.20
        for <Linux-mm@kvack.org>; Wed, 26 Jun 2019 16:15:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=GKskHS9ZrMmpTl7HXRgGF9dvlX1SkdCEtudhd+dfdKc=;
        b=l+92GZoevPNwbrO2SpELGmFbavp3kAEPpj4fRHC8nbptcyO6aZDriaoOEcjIa1mrwE
         aBPU71Su4Kh4eK+y1fSBk0OeFsL0OYOcwDZLFZjKyh4mRadxj4vI0Z9x4IIF6WXXKunl
         7EcEuUG+4OQSsuV6fY6cw94U2ZnWkk6+swqP+Rz9KB/VTU/VT8H1sGoYUi2bY3tfSiUz
         bjiuxCuzr0sBwGWmEnfmrStYvYmudW/HXQvrlPc9f5DIGFUIWkjFG/QjTx5n3p+JWRh0
         7W2xvJ9l2wiv/NBQTx31gsayVyXSIrFiTscBonLpyV+ALooCndoV+Ohngwsx2H+yQdGy
         2QTw==
X-Gm-Message-State: APjAAAWO0+CV3b55yMAk1kFchYx+ie76A7OWstk9AJ1WiimEjzX+2AmT
	o3f4tmerWD3llQjOO6m8zqkj1X8hqzg4OOk5B302+i0Df69ei58I/zirD0yQhaX5GSrrBbKHPk7
	dI4vZe+3G04OtlC4wNLf6hQnhyhP/6CObUdrZyIrU9X1fAdWvnW8tf33qqpgg/vXftw==
X-Received: by 2002:a63:61cb:: with SMTP id v194mr440744pgb.95.1561590939927;
        Wed, 26 Jun 2019 16:15:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz/jkpm7rS0bsF4uSn+A5K+ZF9owe2PW6eC4Ll4ur6xSz4cRaRhR3z4aubOECaTManrmmPC
X-Received: by 2002:a63:61cb:: with SMTP id v194mr440708pgb.95.1561590939226;
        Wed, 26 Jun 2019 16:15:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561590939; cv=none;
        d=google.com; s=arc-20160816;
        b=d+gsKfgs9pQupuIMqPoarpmBtbh3s9CoANq+aUkrJOVrl61Qn0XfdDHYHe+5kFN+n8
         JX1k3cnmgRbr9wzy5ahUuznWCNVhRNZiWOpEA8Cf5TQxooisRcAFq5zwxBGOz1hQy/Gl
         c7wh3gviIlVKIXO9CPS6f9hQ6MXXSo3IQVy2KAkZk8B0LZJfidMHx6j/rkZ2r2lvBXG1
         TgRpVsWG/f0PcSGK/rhiUGfViJfNeevGj6o5vqdZZ4R9kl2AXp/whUOJWx7P+kYO0TY8
         zY6Z3+btJbQQ2bioGg/piEKpONU4kcZssIFTGvU3S4V1p8HhHS/uW0MpohtCKUWUcaL8
         xH0A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=GKskHS9ZrMmpTl7HXRgGF9dvlX1SkdCEtudhd+dfdKc=;
        b=MvLHetTKILHMlK6Xs7g+dVmcxZd8Wbk+uBZFPcLx+jwirvdNr0VbrL+RjiUMbIoqqP
         aX0MnZ+/oH2aNBzpsDQNnR5a4p9DqwhpOC0XxcRDKu0mpcPCwS94vmLyG/clYm4+N5K0
         1bTUZP9CfuUXDyQ+pqAOp39L48LA6WVUzPRF2mbI2S2GV2rIbFPP4ZXjkLu64etaOHRC
         WwdHKckiPRCi31v42TZyGO1LcqEzyPlklf3Q/8qtchk7zihUM1558ysDaGL1NdjXaBFS
         7pAWmOFfy9Yp37tNmbXPIXBRJoIHvaj09Q0JgkES03GJvnJj+OwqoLInAEz9SSpbM5kU
         Fr0g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=uTJS3ibn;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id g1si457765plp.406.2019.06.26.16.15.39
        for <Linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jun 2019 16:15:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=uTJS3ibn;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 54CF421738;
	Wed, 26 Jun 2019 23:15:38 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1561590938;
	bh=0Jq+Gi01hm8xr98U/7QJrcZzZaNW00Tq+R6w9xmYElM=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=uTJS3ibnxftVoPyYA/8YeyMEeGDcIszJf5JIXpLQcw3XJInC4JVGwHZV/uQlqMf+q
	 kVzlgurXyK9w99/0YaZ4Z2EpTw90T7hdzuVlfHQS0VhWvnNeoAe5hv+YeENsvtfKlF
	 gqqDW8oXyejimuteeE6l7sSE4DgKyE+XRRi0l/Oc=
Date: Wed, 26 Jun 2019 16:15:37 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Pingfan Liu <kernelfans@gmail.com>
Cc: Linux-mm@kvack.org, Ira Weiny <ira.weiny@intel.com>, Mike Rapoport
 <rppt@linux.ibm.com>, "Kirill A. Shutemov"
 <kirill.shutemov@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>,
 John Hubbard <jhubbard@nvidia.com>, "Aneesh Kumar K.V"
 <aneesh.kumar@linux.ibm.com>, Christoph Hellwig <hch@lst.de>, Keith Busch
 <keith.busch@intel.com>, Mike Kravetz <mike.kravetz@oracle.com>,
 Linux-kernel@vger.kernel.org
Subject: Re: [PATCHv4] mm/gup: speed up check_and_migrate_cma_pages() on
 huge page
Message-Id: <20190626161537.ae9fcca4f727c12b2a44b471@linux-foundation.org>
In-Reply-To: <1561554600-5274-1-git-send-email-kernelfans@gmail.com>
References: <1561554600-5274-1-git-send-email-kernelfans@gmail.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 26 Jun 2019 21:10:00 +0800 Pingfan Liu <kernelfans@gmail.com> wrote:

> Both hugetlb and thp locate on the same migration type of pageblock, since
> they are allocated from a free_list[]. Based on this fact, it is enough to
> check on a single subpage to decide the migration type of the whole huge
> page. By this way, it saves (2M/4K - 1) times loop for pmd_huge on x86,
> similar on other archs.
> 
> Furthermore, when executing isolate_huge_page(), it avoid taking global
> hugetlb_lock many times, and meanless remove/add to the local link list
> cma_page_list.
> 
> ...
>
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -1342,19 +1342,22 @@ static long check_and_migrate_cma_pages(struct task_struct *tsk,
>  	LIST_HEAD(cma_page_list);
>  
>  check_again:
> -	for (i = 0; i < nr_pages; i++) {
> +	for (i = 0; i < nr_pages;) {
> +
> +		struct page *head = compound_head(pages[i]);
> +		long step = 1;
> +
> +		if (PageCompound(head))

I suspect this would work correctly if the PageCompound test was simply
removed.  Not that I'm really suggesting that it be removed - dunno.

> +			step = (1 << compound_order(head)) - (pages[i] - head);

I don't understand this statement.  Why does the position of this page
in the pages[] array affect anything?  There's an assumption about the
contents of the skipped pages, I assume.

Could we please get a comment in here whcih fully explains the logic
and any assumptions?

