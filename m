Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id CC3F06B258B
	for <linux-mm@kvack.org>; Wed, 22 Aug 2018 13:40:19 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id b5-v6so1143319qtk.4
        for <linux-mm@kvack.org>; Wed, 22 Aug 2018 10:40:19 -0700 (PDT)
Received: from a9-92.smtp-out.amazonses.com (a9-92.smtp-out.amazonses.com. [54.240.9.92])
        by mx.google.com with ESMTPS id j34-v6si2147416qte.55.2018.08.22.10.40.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 22 Aug 2018 10:40:18 -0700 (PDT)
Date: Wed, 22 Aug 2018 17:40:18 +0000
From: Christopher Lameter <cl@linux.com>
Subject: Re: [GIT PULL] XArray for 4.19
In-Reply-To: <20180813161357.GB1199@bombadil.infradead.org>
Message-ID: <0100016562b90938-02b97bb7-eddd-412d-8162-7519a70d4103-000000@email.amazonses.com>
References: <20180813161357.GB1199@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, 13 Aug 2018, Matthew Wilcox wrote:

> Please consider pulling the XArray patch set.  The XArray provides an
> improved interface to the radix tree data structure, providing locking
> as part of the API, specifying GFP flags at allocation time, eliminating
> preloading, less re-walking the tree, more efficient iterations and not
> exposing RCU-protected pointers to its users.

Is this going in this cycle? I have a bunch of stuff on top of this to
enable slab object migration.
