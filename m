Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4A3E06B0003
	for <linux-mm@kvack.org>; Tue,  6 Mar 2018 13:41:39 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id g42so54206ioi.3
        for <linux-mm@kvack.org>; Tue, 06 Mar 2018 10:41:39 -0800 (PST)
Received: from resqmta-ch2-10v.sys.comcast.net (resqmta-ch2-10v.sys.comcast.net. [2001:558:fe21:29:69:252:207:42])
        by mx.google.com with ESMTPS id t6si7769872itd.63.2018.03.06.10.41.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Mar 2018 10:41:38 -0800 (PST)
Date: Tue, 6 Mar 2018 12:41:37 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH 09/25] slub: make ->remote_node_defrag_ratio unsigned
 int
In-Reply-To: <20180305200730.15812-9-adobriyan@gmail.com>
Message-ID: <alpine.DEB.2.20.1803061240080.29393@nuc-kabylake>
References: <20180305200730.15812-1-adobriyan@gmail.com> <20180305200730.15812-9-adobriyan@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: akpm@linux-foundation.org, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org

On Mon, 5 Mar 2018, Alexey Dobriyan wrote:

> ->remote_node_defrag_ratio is in range 0..1000.

This also adds a check and modifies the behavior to return an error code.
Before this patch invalid values were ignored.

Acked-by: Christoph Lameter <cl@linux.com>

> -	err = kstrtoul(buf, 10, &ratio);
> +	err = kstrtouint(buf, 10, &ratio);
>  	if (err)
>  		return err;
> +	if (ratio > 100)
> +		return -ERANGE;
>
> -	if (ratio <= 100)
> -		s->remote_node_defrag_ratio = ratio * 10;
> +	s->remote_node_defrag_ratio = ratio * 10;
>
>  	return length;
>  }
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
