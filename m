Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id BD16B6B000D
	for <linux-mm@kvack.org>; Fri,  5 Oct 2018 17:21:45 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id bh1-v6so12422238plb.15
        for <linux-mm@kvack.org>; Fri, 05 Oct 2018 14:21:45 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id x27-v6si9883648pff.196.2018.10.05.14.21.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Oct 2018 14:21:44 -0700 (PDT)
Date: Fri, 5 Oct 2018 14:21:43 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] mm, page_alloc: set num_movable in move_freepages()
Message-Id: <20181005142143.30032b7a4fb9dc2b587a8c21@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.21.1810051355490.212229@chino.kir.corp.google.com>
References: <alpine.DEB.2.21.1810051355490.212229@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 5 Oct 2018 13:56:39 -0700 (PDT) David Rientjes <rientjes@google.com> wrote:

> If move_freepages() returns 0 because zone_spans_pfn(), *num_movable can

     move_free_pages_block()?           !zone_spans_pfn()?

> hold the value from the stack because it does not get initialized in
> move_freepages().
> 
> Move the initialization to move_freepages_block() to guarantee the value
> actually makes sense.
> 
> This currently doesn't affect its only caller where num_movable != NULL,
> so no bug fix, but just more robust.
> 
> ...
