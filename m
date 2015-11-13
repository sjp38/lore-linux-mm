Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id DD9646B0038
	for <linux-mm@kvack.org>; Fri, 13 Nov 2015 17:58:34 -0500 (EST)
Received: by pacej9 with SMTP id ej9so6353718pac.2
        for <linux-mm@kvack.org>; Fri, 13 Nov 2015 14:58:34 -0800 (PST)
Received: from mail-pa0-x234.google.com (mail-pa0-x234.google.com. [2607:f8b0:400e:c03::234])
        by mx.google.com with ESMTPS id ah5si30211496pbd.102.2015.11.13.14.58.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Nov 2015 14:58:34 -0800 (PST)
Received: by pabfh17 with SMTP id fh17so113395613pab.0
        for <linux-mm@kvack.org>; Fri, 13 Nov 2015 14:58:34 -0800 (PST)
Date: Fri, 13 Nov 2015 14:58:32 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: Loosen MADV_NOHUGEPAGE to enable Qemu postcopy on
 s390
In-Reply-To: <1447341516-18076-1-git-send-email-jjherne@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.10.1511131458210.6173@chino.kir.corp.google.com>
References: <1447341516-18076-1-git-send-email-jjherne@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Jason J. Herne" <jjherne@linux.vnet.ibm.com>
Cc: linux-s390@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, aarcange@redhat.com, borntraeger@de.ibm.com

On Thu, 12 Nov 2015, Jason J. Herne wrote:

> MADV_NOHUGEPAGE processing is too restrictive. kvm already disables
> hugepage but hugepage_madvise() takes the error path when we ask to turn
> on the MADV_NOHUGEPAGE bit and the bit is already on. This causes Qemu's
> new postcopy migration feature to fail on s390 because its first action is
> to madvise the guest address space as NOHUGEPAGE. This patch modifies the
> code so that the operation succeeds without error now.
> 
> Signed-off-by: Jason J. Herne <jjherne@linux.vnet.ibm.com>
> Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
