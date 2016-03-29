Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 8B2886B007E
	for <linux-mm@kvack.org>; Tue, 29 Mar 2016 02:19:54 -0400 (EDT)
Received: by mail-pf0-f175.google.com with SMTP id 4so6885018pfd.0
        for <linux-mm@kvack.org>; Mon, 28 Mar 2016 23:19:54 -0700 (PDT)
Received: from e23smtp02.au.ibm.com (e23smtp02.au.ibm.com. [202.81.31.144])
        by mx.google.com with ESMTPS id v13si10277586pas.199.2016.03.28.23.19.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 28 Mar 2016 23:19:53 -0700 (PDT)
Received: from localhost
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <xinhui@linux.vnet.ibm.com>;
	Tue, 29 Mar 2016 16:19:49 +1000
Received: from d23relay06.au.ibm.com (d23relay06.au.ibm.com [9.185.63.219])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 9151C357805D
	for <linux-mm@kvack.org>; Tue, 29 Mar 2016 17:19:44 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u2T6JXwA53346462
	for <linux-mm@kvack.org>; Tue, 29 Mar 2016 17:19:44 +1100
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u2T6J9V8018767
	for <linux-mm@kvack.org>; Tue, 29 Mar 2016 17:19:09 +1100
Message-ID: <56FA1E33.9050209@linux.vnet.ibm.com>
Date: Tue, 29 Mar 2016 14:18:27 +0800
From: Pan Xinhui <xinhui@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/1] mm/page_alloc: Remove useless parameter of __free_pages_boot_core
References: <1458791480-20324-1-git-send-email-zhlcindy@gmail.com>
In-Reply-To: <1458791480-20324-1-git-send-email-zhlcindy@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zhang <zhlcindy@gmail.com>, mgorman@techsingularity.net, vbabka@suse.cz, akpm@linux-foundation.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Li Zhang <zhlcindy@linux.vnet.ibm.com>

On 2016a1'03ae??24ae?JPY 11:51, Li Zhang wrote:
> From: Li Zhang <zhlcindy@linux.vnet.ibm.com>
> 
> __free_pages_boot_core has parameter pfn which is not used at all.
> So this patch is to make it clean.
> 
> Signed-off-by: Li Zhang <zhlcindy@linux.vnet.ibm.com>

Reviewed-by: Pan Xinhui <xinhui.pan@linux.vnet.ibm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
