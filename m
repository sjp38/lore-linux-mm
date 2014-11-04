Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 5BAB56B00BF
	for <linux-mm@kvack.org>; Tue,  4 Nov 2014 07:30:24 -0500 (EST)
Received: by mail-wi0-f175.google.com with SMTP id ex7so9236034wid.14
        for <linux-mm@kvack.org>; Tue, 04 Nov 2014 04:30:23 -0800 (PST)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.234])
        by mx.google.com with ESMTP id jb20si12169253wic.97.2014.11.04.04.30.23
        for <linux-mm@kvack.org>;
        Tue, 04 Nov 2014 04:30:23 -0800 (PST)
Date: Tue, 4 Nov 2014 14:30:21 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mremap: take anon_vma lock in shared mode
Message-ID: <20141104123021.GB28274@node.dhcp.inet.fi>
References: <1414507237-114852-1-git-send-email-kirill.shutemov@linux.intel.com>
 <alpine.LSU.2.11.1411032204420.15596@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1411032204420.15596@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, akpm@linux-foundation.org
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, riel@redhat.com, walken@google.com, aarcange@redhat.com, linux-mm@kvack.org

On Mon, Nov 03, 2014 at 10:08:31PM -0800, Hugh Dickins wrote:
> On Tue, 28 Oct 2014, Kirill A. Shutemov wrote:
> 
> > There's no modification to anon_vma interval tree. We only need to
> > serialize against exclusive rmap walker who want s to catch all ptes the
> > page is mapped with. Shared lock is enough for that.
> > 
> > Suggested-by: Davidlohr Bueso <dbueso@suse.de>
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> 
> NAK: please read Michel's comment on need_rmap_locks again, there is
> no point in using read locks on anon_vma (and i_mmap) here, those will
> not exclude the read locks on anon_vma (and i_mmap) in the rmap walk,
> while we move ptes around.
> 
> Or am I confused?

Andrew, please drop the patch.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
