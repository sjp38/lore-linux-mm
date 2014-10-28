Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com [209.85.192.50])
	by kanga.kvack.org (Postfix) with ESMTP id 488A4900021
	for <linux-mm@kvack.org>; Tue, 28 Oct 2014 11:47:50 -0400 (EDT)
Received: by mail-qg0-f50.google.com with SMTP id a108so699438qge.23
        for <linux-mm@kvack.org>; Tue, 28 Oct 2014 08:47:50 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 20si2867643qgn.61.2014.10.28.08.47.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Oct 2014 08:47:48 -0700 (PDT)
Message-ID: <544FB517.9090407@redhat.com>
Date: Tue, 28 Oct 2014 11:24:07 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mremap: take anon_vma lock in shared mode
References: <1414507237-114852-1-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1414507237-114852-1-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, akpm@linux-foundation.org
Cc: walken@google.com, aarcange@redhat.com, linux-mm@kvack.org

On 10/28/2014 10:40 AM, Kirill A. Shutemov wrote:
> There's no modification to anon_vma interval tree. We only need to
> serialize against exclusive rmap walker who want s to catch all ptes the
> page is mapped with. Shared lock is enough for that.
>
> Suggested-by: Davidlohr Bueso <dbueso@suse.de>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Acked-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
