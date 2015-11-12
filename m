Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id F0F246B0253
	for <linux-mm@kvack.org>; Thu, 12 Nov 2015 15:55:59 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so75866452pab.0
        for <linux-mm@kvack.org>; Thu, 12 Nov 2015 12:55:59 -0800 (PST)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com. [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id qg3si22126358pbb.100.2015.11.12.12.55.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Nov 2015 12:55:59 -0800 (PST)
Received: by pasz6 with SMTP id z6so78440933pas.2
        for <linux-mm@kvack.org>; Thu, 12 Nov 2015 12:55:59 -0800 (PST)
Date: Thu, 12 Nov 2015 12:55:57 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH V2] mm: vmalloc: don't remove inexistent guard hole in
 remove_vm_area()
In-Reply-To: <1447346238-29153-1-git-send-email-jmarchan@redhat.com>
Message-ID: <alpine.DEB.2.10.1511121255140.10324@chino.kir.corp.google.com>
References: <1447341424-11466-1-git-send-email-jmarchan@redhat.com> <1447346238-29153-1-git-send-email-jmarchan@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Marchand <jmarchan@redhat.com>
Cc: linux-mm@kvack.org, Andrey Ryabinin <ryabinin.a.a@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On Thu, 12 Nov 2015, Jerome Marchand wrote:

> Commit 71394fe50146 ("mm: vmalloc: add flag preventing guard hole
> allocation") missed a spot. Currently remove_vm_area() decreases
> vm->size to "remove" the guard hole page, even when it isn't present.
> All but one users just free the vm_struct rigth away and never access
> vm->size anyway.
> Don't touch the size in remove_vm_area() and have __vunmap() use the
> proper get_vm_area_size() helper.
> 
> Signed-off-by: Jerome Marchand <jmarchan@redhat.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
