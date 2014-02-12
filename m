Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 10C546B0037
	for <linux-mm@kvack.org>; Tue, 11 Feb 2014 19:28:03 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id lf10so8400225pab.32
        for <linux-mm@kvack.org>; Tue, 11 Feb 2014 16:28:03 -0800 (PST)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id wm3si20599197pab.223.2014.02.11.16.28.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 11 Feb 2014 16:28:03 -0800 (PST)
Received: by mail-pa0-f49.google.com with SMTP id hz1so8382191pad.22
        for <linux-mm@kvack.org>; Tue, 11 Feb 2014 16:28:02 -0800 (PST)
Date: Tue, 11 Feb 2014 16:28:00 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [question] how to figure out OOM reason? should dump slab/vmalloc
 info when OOM?
In-Reply-To: <52F9A1D8.7040301@huawei.com>
Message-ID: <alpine.DEB.2.02.1402111627400.29715@chino.kir.corp.google.com>
References: <52DCFC33.80008@huawei.com> <alpine.DEB.2.02.1401202130590.21729@chino.kir.corp.google.com> <52DE6AA0.1000801@huawei.com> <alpine.DEB.2.02.1401211236520.10355@chino.kir.corp.google.com> <52F9A1D8.7040301@huawei.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jianguo Wu <wujianguo@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 11 Feb 2014, Jianguo Wu wrote:

> Thanks for your kindly explanation, do you have any specific plans on this?
> 

We're going to be discussing it at the LSF/mm conference at the end of 
March.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
