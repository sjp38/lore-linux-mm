Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 48266280324
	for <linux-mm@kvack.org>; Fri, 17 Jul 2015 08:16:24 -0400 (EDT)
Received: by pdbbh15 with SMTP id bh15so15621770pdb.1
        for <linux-mm@kvack.org>; Fri, 17 Jul 2015 05:16:24 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id bd3si18468800pdb.113.2015.07.17.05.16.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Jul 2015 05:16:22 -0700 (PDT)
Date: Fri, 17 Jul 2015 05:16:17 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCHv2 1/6] mm: mark most vm_operations_struct const
Message-ID: <20150717121617.GA10394@infradead.org>
References: <1437133993-91885-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1437133993-91885-2-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1437133993-91885-2-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jul 17, 2015 at 02:53:08PM +0300, Kirill A. Shutemov wrote:
> With two excetions (drm/qxl and drm/radeon) all vm_operations_struct
> structs should be constant.

Actually those two really need to be const as well, and the horrible
copy and overwrite hacks badly need to go away.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
