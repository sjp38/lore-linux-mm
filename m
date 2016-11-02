Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 179786B02A1
	for <linux-mm@kvack.org>; Wed,  2 Nov 2016 06:02:35 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id o141so2181835lff.7
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 03:02:35 -0700 (PDT)
Received: from mail-lf0-x22f.google.com (mail-lf0-x22f.google.com. [2a00:1450:4010:c07::22f])
        by mx.google.com with ESMTPS id 72si760265lfq.386.2016.11.02.03.02.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Nov 2016 03:02:33 -0700 (PDT)
Received: by mail-lf0-x22f.google.com with SMTP id t196so8070269lff.3
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 03:02:33 -0700 (PDT)
Date: Wed, 2 Nov 2016 12:58:48 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 01/21] mm: Join struct fault_env and vm_fault
Message-ID: <20161102095848.GB20724@node.shutemov.name>
References: <1478039794-20253-1-git-send-email-jack@suse.cz>
 <1478039794-20253-3-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1478039794-20253-3-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Andrew Morton <akpm@linux-foundation.org>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Tue, Nov 01, 2016 at 11:36:08PM +0100, Jan Kara wrote:
> Currently we have two different structures for passing fault information
> around - struct vm_fault and struct fault_env. DAX will need more
> information in struct vm_fault to handle its faults so the content of
> that structure would become event closer to fault_env. Furthermore it
> would need to generate struct fault_env to be able to call some of the
> generic functions. So at this point I don't think there's much use in
> keeping these two structures separate. Just embed into struct vm_fault
> all that is needed to use it for both purposes.

What about just reference fault_env from vm_fault? We don't always need
vm_fault where we nee fault_env. It may save space on stack for some
codepaths.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
