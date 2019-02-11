Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1E2AAC282CE
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 15:27:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DC24B21B1A
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 15:27:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DC24B21B1A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lwn.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 78EFA8E00F0; Mon, 11 Feb 2019 10:27:09 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 73E378E00EB; Mon, 11 Feb 2019 10:27:09 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6539D8E00F0; Mon, 11 Feb 2019 10:27:09 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 252AF8E00EB
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 10:27:09 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id q20so9652025pls.4
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 07:27:09 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:organization
         :mime-version:content-transfer-encoding;
        bh=zxiIqPClnfzOEwg6Wf33Q/G0gp/wDI+8Xi54LZDMXX0=;
        b=U+bjP6CXzPbMVJUvhgNppN66Xf3HUGfr31et/yEjAIXBO3CH7/EVFb6/j7vzGF+hVY
         11UgzMWaVGycpImmm4QSoAOWG0bqqe4ZAygZAyoItTOxRoKhqS+Y67NB5sPOJqr1CBT8
         L2KlKpV3Zxmq3NesFt4VbY9hRAXWa7vss1U0eM29ViOMukBMSgTpdlZ8AK3nVWk4Fw5z
         vV8UKdOUN+tL7QYZRhpbeWoFmkDS8nYZQQ3HiLFlcIh60UZVUC9M990E6XiRcg0yTLpb
         Ws/QmokPqwT0i63Dif8Z0NUl/YrD2ehNb5cjQ+A6aoRkjpb/SWvOtVZMkY2+qBAW6szf
         NW/Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of corbet@lwn.net designates 45.79.88.28 as permitted sender) smtp.mailfrom=corbet@lwn.net
X-Gm-Message-State: AHQUAuaobM0rcvr1lm7Ag5G5PuLi2E3Abl0C4RFd+Dol/z5m0bEWGR2r
	AoY7cHFlQgWmHD06R15Z69ehH8bgQvqaa4nx+dxQpSU03R4He8KN8W8H1OqHq7cNUeVCAixpe+y
	AXiP5Bb8TD9qN8BzoSxTSnpSH0aHB6rBeJUvD0mGnA5JQyHHKIuOjfLiKXzvQdu3yNg==
X-Received: by 2002:a63:d450:: with SMTP id i16mr33582215pgj.246.1549898828821;
        Mon, 11 Feb 2019 07:27:08 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYjyD2rzigV0Z8HhUQCTIna5tmlcFJFb9X5FkKm2aj7pby3XLTzun5bUg/Td/WT4eMTzmoT
X-Received: by 2002:a63:d450:: with SMTP id i16mr33582168pgj.246.1549898828122;
        Mon, 11 Feb 2019 07:27:08 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549898828; cv=none;
        d=google.com; s=arc-20160816;
        b=LZhkp8gM8IwulzQLwVu+XOaQWnPE/l0mpUgnMvikxcJJWB3V+NNocPSjKdu4AQ1nFB
         J80IDQdJ0iv85nPWUYOY0T/XAVimvo2ozQkuqG2afqaYhy9EeM25aFMHo8VZpCpblUOs
         8q1qiAmjb+cresNZUkLf1DD+23VytS48M8C9Q65q1CDIwqmadw55ccK3i6vaNdzqKUxx
         B0ZEUNp0X0eAc1oL4Fhb7Ro6ZfjHO9xq8rU2+qbOuDTAzAHq1KTV+t7ZeU7F/Q+7QpSS
         DlefnbFpf6Vsaw2W8E6G32eAbnlwr91suQVmF3weuWi8iQNt58ke1+Djnv4w1xBlk28N
         wF2Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:organization:references
         :in-reply-to:message-id:subject:cc:to:from:date;
        bh=zxiIqPClnfzOEwg6Wf33Q/G0gp/wDI+8Xi54LZDMXX0=;
        b=IqMkCAkDH4A/O4ACoSfL+uor4KoA38SIG8LpE5VSB8J22j5pHK3mc/4S8jnq94x20r
         hZM/gwagJLWhN+52vQNv//WzyTSSxuusUvDtJl/Qggb9VbWRzdkcBdy6jzIa/z/dAum7
         CbUawi0QVIvKKe1socv0aJb8ZJh//WjrDKfREOF3mBH0tRQoJyPLifu2yx4WBdfLmjjE
         lBd0U3RxYO+ntTbPreGJ9hNP97QqAxNS4XJ0A0AYfvHHaCfJKZ4GSzJC2JppaKxOc2SN
         vP+sMbP5zWk0MV0i/0QeoEFKLY5lfcUViDsb9d4qAIiIO+U8JqQULOvTRuyEIyh6BIPy
         cjFA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of corbet@lwn.net designates 45.79.88.28 as permitted sender) smtp.mailfrom=corbet@lwn.net
Received: from ms.lwn.net (ms.lwn.net. [45.79.88.28])
        by mx.google.com with ESMTPS id n1si9275269pgq.36.2019.02.11.07.27.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 07:27:08 -0800 (PST)
Received-SPF: pass (google.com: domain of corbet@lwn.net designates 45.79.88.28 as permitted sender) client-ip=45.79.88.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of corbet@lwn.net designates 45.79.88.28 as permitted sender) smtp.mailfrom=corbet@lwn.net
Received: from localhost.localdomain (localhost [127.0.0.1])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by ms.lwn.net (Postfix) with ESMTPSA id E98502F3;
	Mon, 11 Feb 2019 15:27:06 +0000 (UTC)
Date: Mon, 11 Feb 2019 08:27:05 -0700
From: Jonathan Corbet <corbet@lwn.net>
To: Randy Dunlap <rdunlap@infradead.org>, Linux MM <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton
 <akpm@linux-foundation.org>, "linux-doc@vger.kernel.org"
 <linux-doc@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Sergey
 Senozhatsky <sergey.senozhatsky.work@gmail.com>, "Tobin C. Harding"
 <tobin@kernel.org>
Subject: Re: [PATCH] Documentation: fix vm/slub.rst warning
Message-ID: <20190211082705.0ff3d86b@lwn.net>
In-Reply-To: <1e992162-c4ac-fe4e-f1b0-d8a16a51d5e7@infradead.org>
References: <1e992162-c4ac-fe4e-f1b0-d8a16a51d5e7@infradead.org>
Organization: LWN.net
X-Mailer: Claws Mail 3.17.3 (GTK+ 2.24.32; x86_64-redhat-linux-gnu)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 10 Feb 2019 22:34:11 -0800
Randy Dunlap <rdunlap@infradead.org> wrote:

> From: Randy Dunlap <rdunlap@infradead.org>
> 
> Fix markup warning by quoting the '*' character with a backslash.
> 
> Documentation/vm/slub.rst:71: WARNING: Inline emphasis start-string without end-string.
> 
> Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
> ---
>  Documentation/vm/slub.rst |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> --- lnx-50-rc6.orig/Documentation/vm/slub.rst
> +++ lnx-50-rc6/Documentation/vm/slub.rst
> @@ -68,7 +68,7 @@ end of the slab name, in order to cover
>  example, here's how you can poison the dentry cache as well as all kmalloc
>  slabs:
>  
> -	slub_debug=P,kmalloc-*,dentry
> +	slub_debug=P,kmalloc-\*,dentry
>  
>  Red zoning and tracking may realign the slab.  We can just apply sanity checks
>  to the dentry cache with::

The better fix here is to make that a literal block ("slabs::").  Happily
for all of us, Tobin already did that in 11ede50059d0.

Thanks,

jon

