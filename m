Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 965BE6B0253
	for <linux-mm@kvack.org>; Mon, 11 Jul 2016 17:17:04 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 63so142411505pfx.3
        for <linux-mm@kvack.org>; Mon, 11 Jul 2016 14:17:04 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id um11si1376464pab.133.2016.07.11.14.17.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jul 2016 14:17:03 -0700 (PDT)
Date: Mon, 11 Jul 2016 14:17:02 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: gup: Re-define follow_page_mask output parameter
 page_mask usage
Message-Id: <20160711141702.fb1879707aa2bcb290133a43@linux-foundation.org>
In-Reply-To: <1468084625-26999-1-git-send-email-chengang@emindsoft.com.cn>
References: <1468084625-26999-1-git-send-email-chengang@emindsoft.com.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: chengang@emindsoft.com.cn
Cc: vbabka@suse.cz, mhocko@suse.com, kirill.shutemov@linux.intel.com, mingo@kernel.org, dave.hansen@linux.intel.com, dan.j.williams@intel.com, hannes@cmpxchg.org, jack@suse.cz, iamjoonsoo.kim@lge.com, jmarchan@redhat.com, dingel@linux.vnet.ibm.com, oleg@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Chen Gang <gang.chen.5i5j@gmail.com>

On Sun, 10 Jul 2016 01:17:05 +0800 chengang@emindsoft.com.cn wrote:

> For a pure output parameter:
> 
>  - When callee fails, the caller should not assume the output parameter
>    is still valid.
> 
>  - And callee should not assume the pure output parameter must be
>    provided by caller -- caller has right to pass NULL when caller does
>    not care about it.

Sorry, I don't think this one is worth merging really.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
