Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f50.google.com (mail-qa0-f50.google.com [209.85.216.50])
	by kanga.kvack.org (Postfix) with ESMTP id 2B8C76B0166
	for <linux-mm@kvack.org>; Wed, 11 Jun 2014 12:43:38 -0400 (EDT)
Received: by mail-qa0-f50.google.com with SMTP id m5so1697808qaj.37
        for <linux-mm@kvack.org>; Wed, 11 Jun 2014 09:43:37 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id b13si30816429qah.54.2014.06.11.09.43.36
        for <linux-mm@kvack.org>;
        Wed, 11 Jun 2014 09:43:37 -0700 (PDT)
Message-ID: <5398872C.4080607@redhat.com>
Date: Wed, 11 Jun 2014 12:43:24 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: nommu: per-thread vma cache fix
References: <1402396130-22368-1-git-send-email-realmz6@gmail.com>
In-Reply-To: <1402396130-22368-1-git-send-email-realmz6@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Steven Miao (Steven Miao)" <realmz6@gmail.com>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Michel Lespinasse <walken@google.com>, Jerome Marchand <jmarchan@redhat.com>, Jiang Liu <liuj97@gmail.com>, Al Viro <viro@zeniv.linux.org.uk>, Davidlohr Bueso <davidlohr@hp.com>, Choi Gi-yong <yong@gnoy.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Chen Gang <gang.chen@asianux.com>, Mitchel Humpherys <mitchelh@codeaurora.org>, linux-kernel@vger.kernel.org

On 06/10/2014 06:28 AM, Steven Miao (Steven Miao) wrote:
> From: Steven Miao <realmz6@gmail.com>
> 
> mm could be removed from current task struct, using previous vma->vm_mm

> Signed-off-by: Steven Miao <realmz6@gmail.com>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
