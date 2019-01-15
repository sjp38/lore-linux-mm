Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id DD17B8E0002
	for <linux-mm@kvack.org>; Mon, 14 Jan 2019 19:25:20 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id b17so615047pfc.11
        for <linux-mm@kvack.org>; Mon, 14 Jan 2019 16:25:20 -0800 (PST)
Received: from ms.lwn.net (ms.lwn.net. [45.79.88.28])
        by mx.google.com with ESMTPS id 23si1718134pfk.287.2019.01.14.16.25.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Jan 2019 16:25:19 -0800 (PST)
Date: Mon, 14 Jan 2019 17:25:18 -0700
From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: [PATCH] Documentation/sysctl/vm.txt: Fix drop_caches bit number
Message-ID: <20190114172518.5ea0d704@lwn.net>
In-Reply-To: <20190111161410.11831-1-vincent.whitchurch@axis.com>
References: <20190111161410.11831-1-vincent.whitchurch@axis.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vincent Whitchurch <vincent.whitchurch@axis.com>
Cc: linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dave.hansen@linux.intel.com, Vincent Whitchurch <rabinv@axis.com>, Matthew Wilcox <willy@infradead.org>

On Fri, 11 Jan 2019 17:14:10 +0100
Vincent Whitchurch <vincent.whitchurch@axis.com> wrote:

> Bits are usually numbered starting from zero, so 4 should be bit 2, not
> bit 3.
> 
> Suggested-by: Matthew Wilcox <willy@infradead.org>
> Signed-off-by: Vincent Whitchurch <vincent.whitchurch@axis.com>
> ---
>  Documentation/sysctl/vm.txt | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
> index 187ce4f599a2..6af24cdb25cc 100644
> --- a/Documentation/sysctl/vm.txt
> +++ b/Documentation/sysctl/vm.txt
> @@ -237,7 +237,7 @@ used:
>  	cat (1234): drop_caches: 3
>  
>  These are informational only.  They do not mean that anything is wrong
> -with your system.  To disable them, echo 4 (bit 3) into drop_caches.
> +with your system.  To disable them, echo 4 (bit 2) into drop_caches.

Applied, thanks.

jon
