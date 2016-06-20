Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id B469A6B0253
	for <linux-mm@kvack.org>; Mon, 20 Jun 2016 04:27:39 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id a2so22021094lfe.0
        for <linux-mm@kvack.org>; Mon, 20 Jun 2016 01:27:39 -0700 (PDT)
Received: from mail-lf0-x22e.google.com (mail-lf0-x22e.google.com. [2a00:1450:4010:c07::22e])
        by mx.google.com with ESMTPS id w7si10784775lbb.140.2016.06.20.01.27.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Jun 2016 01:27:38 -0700 (PDT)
Received: by mail-lf0-x22e.google.com with SMTP id q132so32701972lfe.3
        for <linux-mm@kvack.org>; Mon, 20 Jun 2016 01:27:38 -0700 (PDT)
Date: Mon, 20 Jun 2016 11:27:35 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] THP: Fix comments of __pmd_trans_huge_lock
Message-ID: <20160620082735.GA27871@node.shutemov.name>
References: <1466200004-6196-1-git-send-email-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1466200004-6196-1-git-send-email-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jun 17, 2016 at 02:46:36PM -0700, Huang, Ying wrote:
> From: Huang Ying <ying.huang@intel.com>
> 
> To make the comments consistent with the already changed code.
> 
> Signed-off-by: "Huang, Ying" <ying.huang@intel.com>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
