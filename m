Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 00EF96B0253
	for <linux-mm@kvack.org>; Mon, 21 Mar 2016 10:32:39 -0400 (EDT)
Received: by mail-wm0-f47.google.com with SMTP id p65so124347101wmp.0
        for <linux-mm@kvack.org>; Mon, 21 Mar 2016 07:32:38 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id c125si14894908wmf.81.2016.03.21.07.32.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Mar 2016 07:32:37 -0700 (PDT)
Date: Mon, 21 Mar 2016 15:32:36 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 26/71] configfs: get rid of PAGE_CACHE_* and
	page_cache_{get,release} macros
Message-ID: <20160321143236.GA12654@lst.de>
References: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com> <1458499278-1516-27-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1458499278-1516-27-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Matthew Wilcox <willy@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Joel Becker <jlbec@evilplan.org>, Christoph Hellwig <hch@lst.de>

Can I don't think sending out per-subsystem patchlets for this global
change is very useful.  That beeing said I support getting rid of 
PAGE_CACHE_SIZE!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
