Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f174.google.com (mail-pf0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 4E0B0828DF
	for <linux-mm@kvack.org>; Tue, 12 Jan 2016 18:56:33 -0500 (EST)
Received: by mail-pf0-f174.google.com with SMTP id q63so72729015pfb.1
        for <linux-mm@kvack.org>; Tue, 12 Jan 2016 15:56:33 -0800 (PST)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com. [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id fb3si8732221pab.106.2016.01.12.15.56.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jan 2016 15:56:32 -0800 (PST)
Received: by mail-pa0-x22e.google.com with SMTP id cy9so347702869pac.0
        for <linux-mm@kvack.org>; Tue, 12 Jan 2016 15:56:32 -0800 (PST)
Date: Tue, 12 Jan 2016 15:56:31 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm/page_isolation: use micro to judge the alignment
In-Reply-To: <20160104141901.414d24a8@debian>
Message-ID: <alpine.DEB.2.10.1601121556160.28831@chino.kir.corp.google.com>
References: <20160104141901.414d24a8@debian>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wang Xiaoqiang <wangxq10@lzu.edu.cn>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org

On Mon, 4 Jan 2016, Wang Xiaoqiang wrote:

> Hi, Naoya,
> 
> This is the final version of the patch.
> 
> Use micro IS_ALIGNED() to judge the aligment, instead of directly
> judging.
> 
> Signed-off-by: Wang Xiaoqiang <wangxq10@lzu.edu.cn>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
