Return-Path: <SRS0=rmuZ=QE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C88E8C282C8
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 20:29:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8C0F020989
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 20:29:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8C0F020989
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2B6878E0003; Mon, 28 Jan 2019 15:29:58 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 240658E0001; Mon, 28 Jan 2019 15:29:58 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0E1008E0003; Mon, 28 Jan 2019 15:29:58 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id B95C78E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 15:29:57 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id p3so12591278plk.9
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 12:29:57 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=wLD708bNd/55rLjpHfYLyxeo48qAcAQBAAdkZxG2PmM=;
        b=QvvcA7/Hp3IdcD2oOf9+0I0jExHsibG0c8I2ic/HJGN9nMdIVPrtUUURo9YP9nqKKd
         qLFGz9utWjGCvGJGp94qrTqjVKFO07efmStLxpfB4dSoJhBu5gDgVneyEB4D/yHrCL56
         FI+xQ3Wp7wqHrAVG5BtNpKdewsqe+L9U76lvmLy2m0Jh2hCa5zqXXzPh+69UFc3Tt5Rn
         bmmnXOi4laNBQwblRy7o1w6z1fj4zBAe1p/Hf4XWO25sLSSY3C0+6XsIcEjgQJqqq2MM
         clQSUm6RynjwBPWcLzxdE8ZPGYm36z4VCpUZus+6yofZa03yG6ZEdCNen7rfA+r3HG4C
         AfdA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: AJcUukf8noDyLdB9yYO5/DYK5rR80Fp/SFv9E/OY8M+AIlC5Eq22zAbu
	DgzhFn6Q0PmTh61LpOQ49lyQjZW/e9tvWHzfrLU4Vla2KZDEUjMcJ5zoGFl7C1YLYWW9rDM6jy6
	sF7n2foTQn/CDA/wFsqsMOUpobQiyzhn+3ukBE5zwg02xJi9V5AdTJtX0cm/nLagYmg==
X-Received: by 2002:a63:83:: with SMTP id 125mr20695859pga.343.1548707397406;
        Mon, 28 Jan 2019 12:29:57 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5AQ7KAqPKChoHHtJq4LRiPTVYm90I8ClrUxssIofutaUlZZgSMHs7WngmapcpxYsMZh3GD
X-Received: by 2002:a63:83:: with SMTP id 125mr20695838pga.343.1548707396729;
        Mon, 28 Jan 2019 12:29:56 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548707396; cv=none;
        d=google.com; s=arc-20160816;
        b=Z4RuhUC5IXKQIQzYD60m8sqz7cL2WSCSqcVHHp5RFAYH0vRaLTE2WLbw5465cjOe8f
         q2cOGKiYPV6LtgYIDDoZprkIWIpsWo0hITAWm+VrkLiNffFB8Db82LSfSeN64DDnh14g
         gPADFjRfpbkSaHIyh8tQ1jUkFwCNb5vUZ5dI7gJ9jCGO5hrqe6ukhaMaciM98oFwfKYA
         UO3gfwr8VQytYfV0qUTKaKcaMEZcN5Z/cZbLNn6PiUg7mUXjVVIw+Qbj3MNsqbZX6xwe
         NGerIbA+ANYbu/71YGiowSirtA+LXUUaei+elRtuMn+sbD1Sit1aOB4Ppifs5O8arnSu
         JlAw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=wLD708bNd/55rLjpHfYLyxeo48qAcAQBAAdkZxG2PmM=;
        b=E8zgHE3zNXiGkN66XLf9qIzRYCezVAaEwi4gCWfFnK1QYEUmeSsz3d6cRNBFf6za7Z
         pT+oqME3tP69UALVxBlG9nrGLfFECC2gw43FWb87oEinXESDovXViWgRS+20WHGmC684
         Ne3tdPkMQrpNx56BjJbqIrW9D8nHxvm66m7VPKyDAq5r1i0A4QqE8dcA4hqkRFRtyAjx
         PVMl0/RSgVc83TGWXeIbK+ZOadUXDiCYwpOsSPRtSyUQCLMQ5T8JnAOmohLicvbo5bmZ
         ahxCs1yXwgUZJiqO+O2HTgUXNYUdu31uxBCBn9/OJl6AxiYKxOHRhh3BFschce20vA61
         9NNA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id b70si16479928pfe.168.2019.01.28.12.29.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 12:29:56 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 1D02E250E;
	Mon, 28 Jan 2019 20:29:56 +0000 (UTC)
Date: Mon, 28 Jan 2019 12:29:54 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: <miles.chen@mediatek.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
 "David Rientjes" <rientjes@google.com>, Joonsoo Kim
 <iamjoonsoo.kim@lge.com>, Jonathan Corbet <corbet@lwn.net>,
 <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>,
 <linux-mediatek@lists.infradead.org>
Subject: Re: [PATCH v2] mm/slub: introduce SLAB_WARN_ON_ERROR
Message-Id: <20190128122954.949c2e6699d6e5ef060a325c@linux-foundation.org>
In-Reply-To: <1548313223-17114-1-git-send-email-miles.chen@mediatek.com>
References: <1548313223-17114-1-git-send-email-miles.chen@mediatek.com>
X-Mailer: Sylpheed 3.6.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 24 Jan 2019 15:00:23 +0800 <miles.chen@mediatek.com> wrote:

> From: Miles Chen <miles.chen@mediatek.com>
> 
> When debugging slab errors in slub.c, sometimes we have to trigger
> a panic in order to get the coredump file. Add a debug option
> SLAB_WARN_ON_ERROR to toggle WARN_ON() when the option is set.
> 
> Change since v1:
> 1. Add a special debug option SLAB_WARN_ON_ERROR and toggle WARN_ON()
> if it is set.
> 2. SLAB_WARN_ON_ERROR can be set by kernel parameter slub_debug.
> 

Hopefully the slab developers will have an opinion on this.

> --- a/Documentation/vm/slub.rst
> +++ b/Documentation/vm/slub.rst
> @@ -52,6 +52,7 @@ Possible debug options are::
>  	A		Toggle failslab filter mark for the cache
>  	O		Switch debugging off for caches that would have
>  			caused higher minimum slab orders
> +	W		Toggle WARN_ON() on slab errors
>  	-		Switch all debugging off (useful if the kernel is
>  			configured with CONFIG_SLUB_DEBUG_ON)

This documentation is poorly phrased.  The term "toggle" means to
invert the value of a boolean: if it was 1, make it 0 and if it was 0,
make it 1.  But that isn't what these options do.  Something like
"enable/disable" would be better.   So...

--- a/Documentation/vm/slub.rst~mm-slub-introduce-slab_warn_on_error-fix
+++ a/Documentation/vm/slub.rst
@@ -49,10 +49,10 @@ Possible debug options are::
 	P		Poisoning (object and padding)
 	U		User tracking (free and alloc)
 	T		Trace (please only use on single slabs)
-	A		Toggle failslab filter mark for the cache
+	A		Enable/disable failslab filter mark for the cache
 	O		Switch debugging off for caches that would have
 			caused higher minimum slab orders
-	W		Toggle WARN_ON() on slab errors
+	W		Enable/disable WARN_ON() on slab errors
 	-		Switch all debugging off (useful if the kernel is
 			configured with CONFIG_SLUB_DEBUG_ON)
 
_

