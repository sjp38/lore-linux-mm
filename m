Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f51.google.com (mail-yh0-f51.google.com [209.85.213.51])
	by kanga.kvack.org (Postfix) with ESMTP id 08C7B6B0035
	for <linux-mm@kvack.org>; Thu,  5 Dec 2013 18:12:22 -0500 (EST)
Received: by mail-yh0-f51.google.com with SMTP id c41so11677236yho.10
        for <linux-mm@kvack.org>; Thu, 05 Dec 2013 15:12:22 -0800 (PST)
Received: from mail-yh0-x22d.google.com (mail-yh0-x22d.google.com [2607:f8b0:4002:c01::22d])
        by mx.google.com with ESMTPS id m9si16714674yha.273.2013.12.05.15.12.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 05 Dec 2013 15:12:22 -0800 (PST)
Received: by mail-yh0-f45.google.com with SMTP id v1so12164918yhn.18
        for <linux-mm@kvack.org>; Thu, 05 Dec 2013 15:12:21 -0800 (PST)
Date: Thu, 5 Dec 2013 15:12:18 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: Add missing dependency in Kconfig
In-Reply-To: <20131205193050.GA13476@lovelace>
Message-ID: <alpine.DEB.2.02.1312051512050.7717@chino.kir.corp.google.com>
References: <20131205193050.GA13476@lovelace>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sima Baymani <sima.baymani@gmail.com>
Cc: linux-mm@kvack.org, tangchen@cn.fujitsu.com, akpm@linux-foundation.org, aquini@redhat.com, linux-kernel@vger.kernel.org, gang.chen@asianux.com, aneesh.kumar@linux.vnet.ibm.com, isimatu.yasuaki@jp.fujitsu.com, kirill.shutemov@linux.intel.com, sjenning@linux.vnet.ibm.com, darrick.wong@oracle.com

On Thu, 5 Dec 2013, Sima Baymani wrote:

> Eliminate the following (rand)config warning by adding missing PROC_FS
> dependency:
> warning: (HWPOISON_INJECT && MEM_SOFT_DIRTY) selects PROC_PAGE_MONITOR
> which has unmet direct dependencies (PROC_FS && MMU)
> 
> Suggested-by: David Rientjes <rientjes@google.com>
> Signed-off-by: Sima Baymani <sima.baymani@gmail.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
