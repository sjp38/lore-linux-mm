Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 54F4C6B0005
	for <linux-mm@kvack.org>; Thu, 31 May 2018 19:37:19 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id j14-v6so13438137pfn.11
        for <linux-mm@kvack.org>; Thu, 31 May 2018 16:37:19 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h187-v6sor3835022pgc.250.2018.05.31.16.37.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 31 May 2018 16:37:18 -0700 (PDT)
Date: Thu, 31 May 2018 16:37:10 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm/shmem: Zero out unused vma fields in
 shmem_pseudo_vma_init()
In-Reply-To: <20180531155256.a5f557c9e620a6d7e85e4ca1@linux-foundation.org>
Message-ID: <alpine.LSU.2.11.1805311635410.13735@eggly.anvils>
References: <20180531135602.20321-1-kirill.shutemov@linux.intel.com> <20180531155256.a5f557c9e620a6d7e85e4ca1@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 31 May 2018, Andrew Morton wrote:
> On Thu, 31 May 2018 16:56:02 +0300 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
> 
> > shmem/tmpfs uses pseudo vma to allocate page with correct NUMA policy.
> > 
> > The pseudo vma doesn't have vm_page_prot set. We are going to encode
> > encryption KeyID in vm_page_prot. Having garbage there causes problems.
> > 
> > Zero out all unused fields in the pseudo vma.
> > 
> 
> So there are no known problems in the current mainline kernel?

Correct - if we limit ourselves to the area of the shmem pseudo-vma :)

Hugh
