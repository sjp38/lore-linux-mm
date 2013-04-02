Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 0A2416B0037
	for <linux-mm@kvack.org>; Tue,  2 Apr 2013 18:34:00 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id kl13so544194pab.4
        for <linux-mm@kvack.org>; Tue, 02 Apr 2013 15:34:00 -0700 (PDT)
Date: Tue, 2 Apr 2013 15:33:58 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: prevent mmap_cache race in find_vma()
In-Reply-To: <3ae9b7e77e8428cfeb34c28ccf4a25708cbea1be.1364938782.git.jstancek@redhat.com>
Message-ID: <alpine.DEB.2.02.1304021532220.25286@chino.kir.corp.google.com>
References: <3ae9b7e77e8428cfeb34c28ccf4a25708cbea1be.1364938782.git.jstancek@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Stancek <jstancek@redhat.com>
Cc: linux-mm@kvack.org

On Tue, 2 Apr 2013, Jan Stancek wrote:

> find_vma() can be called by multiple threads with read lock
> held on mm->mmap_sem and any of them can update mm->mmap_cache.
> Prevent compiler from re-fetching mm->mmap_cache, because other
> readers could update it in the meantime:
> 

FWIW, ACCESS_ONCE() does not guarantee that the compiler will not refetch 
mm->mmap_cache whatsoever; there is nothing that prevents this either in 
the C standard.  You'll be relying solely on gcc's implementation of how 
it dereferences volatile-qualified pointers.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
