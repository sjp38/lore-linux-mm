Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id 3FEEB6B0035
	for <linux-mm@kvack.org>; Tue, 19 Nov 2013 11:31:43 -0500 (EST)
Received: by mail-pb0-f50.google.com with SMTP id rr13so2134078pbb.9
        for <linux-mm@kvack.org>; Tue, 19 Nov 2013 08:31:42 -0800 (PST)
Received: from psmtp.com ([74.125.245.160])
        by mx.google.com with SMTP id oy2si12014473pbc.279.2013.11.19.08.31.38
        for <linux-mm@kvack.org>;
        Tue, 19 Nov 2013 08:31:39 -0800 (PST)
Date: Tue, 19 Nov 2013 08:31:33 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] Reimplement old functionality of vm_munmap to
 vm_munmap_mm
Message-ID: <20131119163133.GA18355@infradead.org>
References: <1384878592-194909-1-git-send-email-jcuster@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1384878592-194909-1-git-send-email-jcuster@sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Custer <jcuster@sgi.com>
Cc: linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jiang Liu <jiang.liu@huawei.com>, Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, Oleg Nesterov <oleg@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org

On Tue, Nov 19, 2013 at 10:29:52AM -0600, James Custer wrote:
> Commit bfce281c287a427d0841fadf5d59242757b4e620 killed the mm parameter to
> vm_munmap. Although the mm parameter was not used in any in-tree kernel
> modules, it is used by some out-of-tree modules.

Which doesn't matter at all.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
