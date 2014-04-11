Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id EB2066B0035
	for <linux-mm@kvack.org>; Thu, 10 Apr 2014 20:22:14 -0400 (EDT)
Received: by mail-ig0-f170.google.com with SMTP id uq10so1444711igb.1
        for <linux-mm@kvack.org>; Thu, 10 Apr 2014 17:22:14 -0700 (PDT)
Received: from mail-ie0-x235.google.com (mail-ie0-x235.google.com [2607:f8b0:4001:c03::235])
        by mx.google.com with ESMTPS id lp10si583100igb.41.2014.04.10.17.22.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 10 Apr 2014 17:22:14 -0700 (PDT)
Received: by mail-ie0-f181.google.com with SMTP id tp5so4467900ieb.26
        for <linux-mm@kvack.org>; Thu, 10 Apr 2014 17:22:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <53470E26.2030306@cybernetics.com>
References: <53470E26.2030306@cybernetics.com>
Date: Fri, 11 Apr 2014 02:22:13 +0200
Message-ID: <CANq1E4RWf_VbzF+dPYhzHKJvnrh86me5KajmaaB1u9f9FLzftA@mail.gmail.com>
Subject: Re: [PATCH 2/6] shm: add sealing API
From: David Herrmann <dh.herrmann@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Battersby <tonyb@cybernetics.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>

Hi

On Thu, Apr 10, 2014 at 11:33 PM, Tony Battersby <tonyb@cybernetics.com> wrote:
> For O_DIRECT the kernel pins the submitted pages in memory for DMA by
> incrementing the page reference counts when the I/O is submitted,
> allowing the pages to be modified by DMA even if they are no longer
> mapped in the address space of the process.  This is different from a
> regular read(), which uses the CPU to copy the data and will fail if the
> pages are not mapped.

Can you please provide an example code-path? For instance,
file_read_actor() does not pin any pages but only keeps the user-space
address and resolves it once it has data to write.

Thanks
David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
