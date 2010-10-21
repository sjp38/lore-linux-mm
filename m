Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 9D4CE5F0040
	for <linux-mm@kvack.org>; Thu, 21 Oct 2010 16:00:20 -0400 (EDT)
Date: Thu, 21 Oct 2010 13:55:26 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] fix error reporting in move_pages syscall
In-Reply-To: <20101019101505.GG10207@redhat.com>
Message-ID: <alpine.DEB.2.00.1010211355140.30295@router.home>
References: <20101019101505.GG10207@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 19 Oct 2010, Gleb Natapov wrote:

> vma returned by find_vma does not necessary include given address. If
> this happens code tries to follow page outside of any vma and returns
> ENOENT instead of EFAULT.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
