Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id F28FD6B0069
	for <linux-mm@kvack.org>; Tue,  2 Dec 2014 07:08:29 -0500 (EST)
Received: by mail-wi0-f178.google.com with SMTP id em10so1240018wid.5
        for <linux-mm@kvack.org>; Tue, 02 Dec 2014 04:08:29 -0800 (PST)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.195])
        by mx.google.com with ESMTP id y8si34662385wjx.160.2014.12.02.04.08.29
        for <linux-mm@kvack.org>;
        Tue, 02 Dec 2014 04:08:29 -0800 (PST)
Date: Tue, 2 Dec 2014 14:08:24 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [patch 3/3] mm: memory: merge shared-writable dirtying branches
 in do_wp_page()
Message-ID: <20141202120824.GD22683@node.dhcp.inet.fi>
References: <1417474682-29326-1-git-send-email-hannes@cmpxchg.org>
 <1417474682-29326-3-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1417474682-29326-3-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Dec 01, 2014 at 05:58:02PM -0500, Johannes Weiner wrote:
> Whether there is a vm_ops->page_mkwrite or not, the page dirtying is
> pretty much the same.  Make sure the page references are the same in
> both cases, then merge the two branches.
> 
> It's tempting to go even further and page-lock the !page_mkwrite case,
> to get it in line with everybody else setting the page table and thus
> further simplify the model.  But that's not quite compelling enough to
> justify dropping the pte lock, then relocking and verifying the entry
> for filesystems without ->page_mkwrite, which notably includes tmpfs.
> Leave it for now and lock the page late in the !page_mkwrite case.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

This would conflict with other patchset of do_wp_page() cleanups, but look
good.

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
