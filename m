Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 6EC8C280324
	for <linux-mm@kvack.org>; Fri, 17 Jul 2015 08:18:06 -0400 (EDT)
Received: by pdbbh15 with SMTP id bh15so15640576pdb.1
        for <linux-mm@kvack.org>; Fri, 17 Jul 2015 05:18:06 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id v5si18497861pdb.7.2015.07.17.05.18.04
        for <linux-mm@kvack.org>;
        Fri, 17 Jul 2015 05:18:05 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <20150717121617.GA10394@infradead.org>
References: <1437133993-91885-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1437133993-91885-2-git-send-email-kirill.shutemov@linux.intel.com>
 <20150717121617.GA10394@infradead.org>
Subject: Re: [PATCHv2 1/6] mm: mark most vm_operations_struct const
Content-Transfer-Encoding: 7bit
Message-Id: <20150717121742.AACED196@black.fi.intel.com>
Date: Fri, 17 Jul 2015 15:17:42 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Christoph Hellwig wrote:
> On Fri, Jul 17, 2015 at 02:53:08PM +0300, Kirill A. Shutemov wrote:
> > With two excetions (drm/qxl and drm/radeon) all vm_operations_struct
> > structs should be constant.
> 
> Actually those two really need to be const as well, and the horrible
> copy and overwrite hacks badly need to go away.

Patches are welcome ;)

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
