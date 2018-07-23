Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id E2A256B0003
	for <linux-mm@kvack.org>; Mon, 23 Jul 2018 16:19:19 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id u4-v6so990484pgr.2
        for <linux-mm@kvack.org>; Mon, 23 Jul 2018 13:19:19 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z125-v6sor2381824pgb.426.2018.07.23.13.19.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 23 Jul 2018 13:19:18 -0700 (PDT)
Date: Mon, 23 Jul 2018 13:19:16 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm/mempool: add missing parameter description
In-Reply-To: <1532336274-26228-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.21.1807231319040.105582@chino.kir.corp.google.com>
References: <1532336274-26228-1-git-send-email-rppt@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 23 Jul 2018, Mike Rapoport wrote:

> The kernel-doc for mempool_init function is missing the description of the
> pool parameter. Add it.
> 
> Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>

Acked-by: David Rientjes <rientjes@google.com>

My b.
