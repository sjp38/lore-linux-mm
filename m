Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f182.google.com (mail-pf0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 56FB9828E5
	for <linux-mm@kvack.org>; Mon,  4 Apr 2016 19:26:47 -0400 (EDT)
Received: by mail-pf0-f182.google.com with SMTP id n1so49104431pfn.2
        for <linux-mm@kvack.org>; Mon, 04 Apr 2016 16:26:47 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTPS id un9si3377948pac.14.2016.04.04.16.26.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Apr 2016 16:26:46 -0700 (PDT)
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id DC4CB202EB
	for <linux-mm@kvack.org>; Mon,  4 Apr 2016 23:26:45 +0000 (UTC)
Received: from mail-lf0-f41.google.com (mail-lf0-f41.google.com [209.85.215.41])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 639262024F
	for <linux-mm@kvack.org>; Mon,  4 Apr 2016 23:26:44 +0000 (UTC)
Received: by mail-lf0-f41.google.com with SMTP id g184so118990893lfb.3
        for <linux-mm@kvack.org>; Mon, 04 Apr 2016 16:26:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <570288E1.4060203@suse.cz>
References: <1459754566.19748.9.camel@kernel.org>
	<570288E1.4060203@suse.cz>
Date: Mon, 4 Apr 2016 16:26:42 -0700
Message-ID: <CAF1ivSaLX7q=52KSvqsvGiHB6M+JmGFDHVCRtNKXYRsyThT93w@mail.gmail.com>
Subject: Re: /proc/meminfo question
From: Ming Lin <mlin@kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Ming Lin <mlin@kernel.org>, linux-mm <linux-mm@kvack.org>, Wu Fengguang <fengguang.wu@intel.com>

On Mon, Apr 4, 2016 at 8:31 AM, Vlastimil Babka <vbabka@suse.cz> wrote:
>
>
> For debugging such leaks I suggest you try the page_owner functionality
> instead.

Hi Vlastimil,

"page_owner" is a great tool!
I have found the leak and fixed it.

Thanks.

>
> Vlastimil

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
