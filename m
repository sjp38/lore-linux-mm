Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 16A2A6B005D
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 19:45:58 -0400 (EDT)
Date: Wed, 5 Sep 2012 01:45:55 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm: fix potential anon_vma locking issue in mprotect()
Message-ID: <20120904234555.GO3334@redhat.com>
References: <1346801989-18274-1-git-send-email-walken@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1346801989-18274-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org

On Tue, Sep 04, 2012 at 04:39:49PM -0700, Michel Lespinasse wrote:
> This change fixes an anon_vma locking issue in the following situation:
> - vma has no anon_vma
> - next has an anon_vma
> - vma is being shrunk / next is being expanded, due to an mprotect call
> 
> We need to take next's anon_vma lock to avoid races with rmap users
> (such as page migration) while next is being expanded.
> 
> Signed-off-by: Michel Lespinasse <walken@google.com>

Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
