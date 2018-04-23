Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9BF4C6B0003
	for <linux-mm@kvack.org>; Mon, 23 Apr 2018 15:49:26 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e20so6037900pff.14
        for <linux-mm@kvack.org>; Mon, 23 Apr 2018 12:49:26 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 4-v6si12335698pld.371.2018.04.23.12.49.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 23 Apr 2018 12:49:25 -0700 (PDT)
Date: Mon, 23 Apr 2018 12:49:17 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v5] fs: dax: Adding new return type vm_fault_t
Message-ID: <20180423194917.GF13383@bombadil.infradead.org>
References: <20180423180625.GA16101@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180423180625.GA16101@jordon-HP-15-Notebook-PC>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: jack@suse.cz, viro@zeniv.linux.org.uk, ross.zwisler@linux.intel.com, akpm@linux-foundation.org, dan.j.williams@intel.com, mhocko@suse.com, kirill.shutemov@linux.intel.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Apr 23, 2018 at 11:36:25PM +0530, Souptick Joarder wrote:
> If the insertion of PTE failed because someone else
> already added a different entry in the mean time, we
> treat that as success as we assume the same entry was
> actually inserted.

No, Jan said to *make it a comment*.  In the source file.  That's why
he formatted it with the /* */.  Not in the changelog.
