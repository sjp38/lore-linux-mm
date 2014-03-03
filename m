Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 143886B0035
	for <linux-mm@kvack.org>; Mon,  3 Mar 2014 06:07:53 -0500 (EST)
Received: by mail-pd0-f182.google.com with SMTP id g10so3570011pdj.41
        for <linux-mm@kvack.org>; Mon, 03 Mar 2014 03:07:52 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id po10si10287532pab.218.2014.03.03.03.07.51
        for <linux-mm@kvack.org>;
        Mon, 03 Mar 2014 03:07:52 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <CACQD4-4bbwk_LOUVamTyB6V+Fg_F+Q4q2g8DxroTM7YiA=eJzQ@mail.gmail.com>
References: <1393625931-2858-1-git-send-email-quning@google.com>
 <1393625931-2858-2-git-send-email-quning@google.com>
 <alpine.LSU.2.11.1402281657520.976@eggly.anvils>
 <CACQD4-4bbwk_LOUVamTyB6V+Fg_F+Q4q2g8DxroTM7YiA=eJzQ@mail.gmail.com>
Subject: Re: [PATCH 1/1] mm: implement ->map_pages for shmem/tmpfs
Content-Transfer-Encoding: 7bit
Message-Id: <20140303110747.01F2DE0098@blue.fi.intel.com>
Date: Mon,  3 Mar 2014 13:07:46 +0200 (EET)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ning Qu <quning@google.com>, Hugh Dickins <hughd@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Ning Qu wrote:
> Btw, should we first check if page returned by radix_tree_deref_slot is NULL?

Yes, we should. I don't know how I missed that. :(

The patch below should address both issues.
