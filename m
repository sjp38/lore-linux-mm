Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f178.google.com (mail-yk0-f178.google.com [209.85.160.178])
	by kanga.kvack.org (Postfix) with ESMTP id 5D05682FC4
	for <linux-mm@kvack.org>; Thu, 24 Dec 2015 20:09:37 -0500 (EST)
Received: by mail-yk0-f178.google.com with SMTP id x184so234743241yka.3
        for <linux-mm@kvack.org>; Thu, 24 Dec 2015 17:09:37 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id p5si32448438ywd.331.2015.12.24.17.09.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Dec 2015 17:09:36 -0800 (PST)
Subject: Re: [PATCH 3/4] mm: stop __munlock_pagevec_fill() if THP enounted
References: <1450957883-96356-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1450957883-96356-4-git-send-email-kirill.shutemov@linux.intel.com>
From: Sasha Levin <sasha.levin@oracle.com>
Message-ID: <567C9749.6000205@oracle.com>
Date: Thu, 24 Dec 2015 20:09:29 -0500
MIME-Version: 1.0
In-Reply-To: <1450957883-96356-4-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org

On 12/24/2015 06:51 AM, Kirill A. Shutemov wrote:
> THP is properly handled in munlock_vma_pages_range().
> 
> It fixes crashes like this:
>  http://lkml.kernel.org/r/565C5C38.3040705@oracle.com
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Looks like this issue is fixed for me.

	Tested-by: Sasha Levin <sasha.levin@oracle.com>


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
