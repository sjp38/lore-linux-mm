Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id C3DA16B0031
	for <linux-mm@kvack.org>; Tue,  1 Jul 2014 18:09:15 -0400 (EDT)
Received: by mail-ig0-f169.google.com with SMTP id c1so5830522igq.4
        for <linux-mm@kvack.org>; Tue, 01 Jul 2014 15:09:15 -0700 (PDT)
Received: from mail-ig0-x22e.google.com (mail-ig0-x22e.google.com [2607:f8b0:4001:c05::22e])
        by mx.google.com with ESMTPS id me8si18337378igb.20.2014.07.01.15.09.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 01 Jul 2014 15:09:14 -0700 (PDT)
Received: by mail-ig0-f174.google.com with SMTP id l13so6034918iga.1
        for <linux-mm@kvack.org>; Tue, 01 Jul 2014 15:09:14 -0700 (PDT)
Date: Tue, 1 Jul 2014 15:09:12 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/2] mm,hugetlb: make unmap_ref_private() return void
In-Reply-To: <1404246097-18810-1-git-send-email-davidlohr@hp.com>
Message-ID: <alpine.DEB.2.02.1407011508570.4004@chino.kir.corp.google.com>
References: <1404246097-18810-1-git-send-email-davidlohr@hp.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: akpm@linux-foundation.org, aswin@hp.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 1 Jul 2014, Davidlohr Bueso wrote:

> This function always returns 1, thus no need to check return value
> in hugetlb_cow(). By doing so, we can get rid of the unnecessary WARN_ON
> call. While this logic perhaps existed as a way of identifying future
> unmap_ref_private() mishandling, reality is it serves no apparent purpose.
> 
> Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
