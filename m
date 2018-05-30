Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 075F06B0005
	for <linux-mm@kvack.org>; Wed, 30 May 2018 02:12:11 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id p12-v6so7831551qtg.5
        for <linux-mm@kvack.org>; Tue, 29 May 2018 23:12:11 -0700 (PDT)
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id b18-v6sor22141665qtp.130.2018.05.29.23.12.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 29 May 2018 23:12:10 -0700 (PDT)
Date: Tue, 29 May 2018 23:12:07 -0700
In-Reply-To: <20180529025722.GA25784@bombadil.infradead.org>
Message-Id: <xr93sh69wu2w.fsf@gthelen.svl.corp.google.com>
Mime-Version: 1.0
References: <20180529024025.58353-1-gthelen@google.com> <20180529025722.GA25784@bombadil.infradead.org>
Subject: Re: [PATCH] mm: convert scan_control.priority int => byte
From: Greg Thelen <gthelen@google.com>
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Matthew Wilcox <willy@infradead.org> wrote:

> On Mon, May 28, 2018 at 07:40:25PM -0700, Greg Thelen wrote:
>> Reclaim priorities range from 0..12(DEF_PRIORITY).
>> scan_control.priority is a 4 byte int, which is overkill.
>> 
>> Since commit 6538b8ea886e ("x86_64: expand kernel stack to 16K") x86_64
>> stack overflows are not an issue.  But it's inefficient to use 4 bytes
>> for priority.
>
> If you're looking to shave a few more bytes, allocation order can fit
> in a u8 too (can't be more than 6 bits, and realistically won't be more
> than 4 bits).  reclaim_idx likewise will fit in a u8, and actually won't
> be more than 3 bits.

Nod.  Good tip.  Included in ("[PATCH v2] mm: condense scan_control").

> I am sceptical that nr_to_reclaim should really be an unsigned long; I
> don't think we should be trying to free 4 billion pages in a single call.
> nr_scanned might be over 4 billion (!) but nr_reclaimed can probably
> shrink to unsigned int along with nr_to_reclaim.

Agreed.  For patch simplicity, I'll pass on this for now.
