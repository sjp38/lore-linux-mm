Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 737816B0038
	for <linux-mm@kvack.org>; Mon,  2 Feb 2015 17:35:43 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id kx10so87789059pab.12
        for <linux-mm@kvack.org>; Mon, 02 Feb 2015 14:35:43 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id ku8si151963pab.155.2015.02.02.14.35.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Feb 2015 14:35:42 -0800 (PST)
Date: Mon, 2 Feb 2015 14:35:41 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC PATCH] mm: madvise: Ignore repeated MADV_DONTNEED hints
Message-Id: <20150202143541.1efdd2b571413200cb9a4698@linux-foundation.org>
In-Reply-To: <20150202221824.GN2395@suse.de>
References: <20150202165525.GM2395@suse.de>
	<20150202140506.392ff6920743f19ea44cff59@linux-foundation.org>
	<20150202221824.GN2395@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org

On Mon, 2 Feb 2015 22:18:24 +0000 Mel Gorman <mgorman@suse.de> wrote:

> > Is there something
> > preventing this from being addressed within glibc?
>  
> I doubt it other than I expect they'll punt it back and blame either the
> application for being stupid or the kernel for being slow.

*Is* the application being stupid?  What is it actually doing? 
Something like

pthread_routine()
{
	p = malloc(X);
	do_some(work);
	free(p);
	return;
}

?

If so, that doesn't seem stupid?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
