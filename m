Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0D8EA6B000D
	for <linux-mm@kvack.org>; Sat, 21 Apr 2018 15:34:19 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id v14so4095400pgq.11
        for <linux-mm@kvack.org>; Sat, 21 Apr 2018 12:34:19 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id v9-v6si3829703plz.33.2018.04.21.12.34.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 21 Apr 2018 12:34:14 -0700 (PDT)
Date: Sat, 21 Apr 2018 12:34:09 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm: memory: Introduce new vmf_insert_mixed_mkwrite
Message-ID: <20180421193409.GD14610@bombadil.infradead.org>
References: <20180421170540.GA17849@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180421170540.GA17849@jordon-HP-15-Notebook-PC>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: hughd@google.com, minchan@kernel.org, ying.huang@intel.com, ross.zwisler@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org

On Sat, Apr 21, 2018 at 10:35:40PM +0530, Souptick Joarder wrote:
> As of now vm_insert_mixed_mkwrite() is only getting
> invoked from fs/dax.c, so this change has to go first
> in linus tree before changes in dax.

No.  One patch which changes both at the same time.  The history should
be bisectable so that it compiles and works at every point.

The rest of the patch looks good.
