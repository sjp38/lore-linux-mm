Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 892D46B0069
	for <linux-mm@kvack.org>; Tue,  2 Dec 2014 07:00:23 -0500 (EST)
Received: by mail-wi0-f178.google.com with SMTP id em10so1215002wid.5
        for <linux-mm@kvack.org>; Tue, 02 Dec 2014 04:00:23 -0800 (PST)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.195])
        by mx.google.com with ESMTP id bd7si49826198wib.75.2014.12.02.04.00.22
        for <linux-mm@kvack.org>;
        Tue, 02 Dec 2014 04:00:22 -0800 (PST)
Date: Tue, 2 Dec 2014 14:00:15 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [patch 2/3] mm: memory: remove ->vm_file check on shared
 writable vmas
Message-ID: <20141202120015.GC22683@node.dhcp.inet.fi>
References: <1417474682-29326-1-git-send-email-hannes@cmpxchg.org>
 <1417474682-29326-2-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1417474682-29326-2-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Dec 01, 2014 at 05:58:01PM -0500, Johannes Weiner wrote:
> The only way a VMA can have shared and writable semantics is with a
> backing file.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
