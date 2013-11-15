Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f178.google.com (mail-ie0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id 0C6E96B0036
	for <linux-mm@kvack.org>; Fri, 15 Nov 2013 10:54:33 -0500 (EST)
Received: by mail-ie0-f178.google.com with SMTP id aq17so4914121iec.23
        for <linux-mm@kvack.org>; Fri, 15 Nov 2013 07:54:32 -0800 (PST)
Received: from psmtp.com ([74.125.245.135])
        by mx.google.com with SMTP id sd2si2382222pbb.109.2013.11.15.07.54.29
        for <linux-mm@kvack.org>;
        Fri, 15 Nov 2013 07:54:30 -0800 (PST)
Message-ID: <5286437E.6040905@sr71.net>
Date: Fri, 15 Nov 2013 07:53:34 -0800
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 3/4] mm/vmalloc.c: Allow lowmem to be tracked in vmalloc
References: <1384212412-21236-1-git-send-email-lauraa@codeaurora.org> <1384212412-21236-4-git-send-email-lauraa@codeaurora.org> <52850C37.1080506@sr71.net> <5285A896.3030204@codeaurora.org>
In-Reply-To: <5285A896.3030204@codeaurora.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org
Cc: Neeti Desai <neetid@codeaurora.org>

On 11/14/2013 08:52 PM, Laura Abbott wrote:
> free (ptr) {
>     if (is_vmalloc_addr(ptr)
>         vfree
>     else
>         kfree
> }
> 
> so my hypothesis would be that any path would have to be willing to take
> the penalty of vmalloc anyway. The actual cost would depend on the
> vmalloc / kmalloc ratio. I haven't had a chance to get profiling data
> yet to see the performance difference.

Well, either that, or these kinds of things where it is a fallback:

>         hc = kmalloc(hsize, GFP_NOFS | __GFP_NOWARN);
>         if (hc == NULL)
>                 hc = __vmalloc(hsize, GFP_NOFS, PAGE_KERNEL);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
