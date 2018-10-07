Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id B85056B000A
	for <linux-mm@kvack.org>; Sun,  7 Oct 2018 18:35:39 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id g6-v6so15440331plo.0
        for <linux-mm@kvack.org>; Sun, 07 Oct 2018 15:35:39 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id a8-v6sor11345843plz.7.2018.10.07.15.35.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 07 Oct 2018 15:35:38 -0700 (PDT)
Date: Sun, 7 Oct 2018 15:35:36 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, page_alloc: set num_movable in move_freepages()
In-Reply-To: <20181005142143.30032b7a4fb9dc2b587a8c21@linux-foundation.org>
Message-ID: <alpine.DEB.2.21.1810071535080.189597@chino.kir.corp.google.com>
References: <alpine.DEB.2.21.1810051355490.212229@chino.kir.corp.google.com> <20181005142143.30032b7a4fb9dc2b587a8c21@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 5 Oct 2018, Andrew Morton wrote:

> On Fri, 5 Oct 2018 13:56:39 -0700 (PDT) David Rientjes <rientjes@google.com> wrote:
> 
> > If move_freepages() returns 0 because zone_spans_pfn(), *num_movable can
> 
>      move_free_pages_block()?           !zone_spans_pfn()?
> 

move_freepages_block() more accurately, yes.  And yes, it depends on the 
return value of zone_spans_pfn().
