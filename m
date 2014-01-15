Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-gg0-f177.google.com (mail-gg0-f177.google.com [209.85.161.177])
	by kanga.kvack.org (Postfix) with ESMTP id 427496B0035
	for <linux-mm@kvack.org>; Tue, 14 Jan 2014 23:54:27 -0500 (EST)
Received: by mail-gg0-f177.google.com with SMTP id f4so376170ggn.36
        for <linux-mm@kvack.org>; Tue, 14 Jan 2014 20:54:26 -0800 (PST)
Received: from mail-yh0-x230.google.com (mail-yh0-x230.google.com [2607:f8b0:4002:c01::230])
        by mx.google.com with ESMTPS id m9si3575942yha.48.2014.01.14.20.54.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 14 Jan 2014 20:54:26 -0800 (PST)
Received: by mail-yh0-f48.google.com with SMTP id f11so386140yha.35
        for <linux-mm@kvack.org>; Tue, 14 Jan 2014 20:54:26 -0800 (PST)
Date: Tue, 14 Jan 2014 20:54:23 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v3 1/5] slab: factor out calculate nr objects in
 cache_estimate
In-Reply-To: <1385974183-31423-2-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <alpine.DEB.2.02.1401142054090.7751@chino.kir.corp.google.com>
References: <1385974183-31423-1-git-send-email-iamjoonsoo.kim@lge.com> <1385974183-31423-2-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>

On Mon, 2 Dec 2013, Joonsoo Kim wrote:

> This logic is not simple to understand so that making separate function
> helping readability. Additionally, we can use this change in the
> following patch which implement for freelist to have another sized index
> in according to nr objects.
> 
> Acked-by: Christoph Lameter <cl@linux.com>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
