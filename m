Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id 0402C6B0031
	for <linux-mm@kvack.org>; Tue,  1 Jul 2014 19:36:00 -0400 (EDT)
Received: by mail-ig0-f171.google.com with SMTP id h18so6083179igc.4
        for <linux-mm@kvack.org>; Tue, 01 Jul 2014 16:36:00 -0700 (PDT)
Received: from mail-ig0-x233.google.com (mail-ig0-x233.google.com [2607:f8b0:4001:c05::233])
        by mx.google.com with ESMTPS id r3si36505126icl.89.2014.07.01.16.35.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 01 Jul 2014 16:36:00 -0700 (PDT)
Received: by mail-ig0-f179.google.com with SMTP id uq10so6030627igb.0
        for <linux-mm@kvack.org>; Tue, 01 Jul 2014 16:35:58 -0700 (PDT)
Date: Tue, 1 Jul 2014 16:35:57 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: make copy_pte_range static again
In-Reply-To: <1404202674-11648-1-git-send-email-jmarchan@redhat.com>
Message-ID: <alpine.DEB.2.02.1407011635440.15139@chino.kir.corp.google.com>
References: <1404202674-11648-1-git-send-email-jmarchan@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Marchand <jmarchan@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>

On Tue, 1 Jul 2014, Jerome Marchand wrote:

> Commit 71e3aac (thp: transparent hugepage core) adds copy_pte_range
> prototype to huge_mm.h. I'm not sure why (or if) this function have
> been used outside of memory.c, but it currently isn't.
> This patch makes copy_pte_range() static again.
> 
> Signed-off-by: Jerome Marchand <jmarchan@redhat.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
