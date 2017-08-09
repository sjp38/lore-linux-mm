Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9A4C76B025F
	for <linux-mm@kvack.org>; Wed,  9 Aug 2017 06:27:47 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id x28so7674339wma.7
        for <linux-mm@kvack.org>; Wed, 09 Aug 2017 03:27:47 -0700 (PDT)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id y28si3884060edi.306.2017.08.09.03.27.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Aug 2017 03:27:46 -0700 (PDT)
Received: by mail-wm0-x241.google.com with SMTP id x64so6269170wmg.1
        for <linux-mm@kvack.org>; Wed, 09 Aug 2017 03:27:46 -0700 (PDT)
Date: Wed, 9 Aug 2017 13:27:43 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm/rmap/mmu_notifier: restore
 mmu_notifier_invalidate_page() semantic
Message-ID: <20170809102743.onfujwpwuli6quc5@node.shutemov.name>
References: <20170808220820.16503-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170808220820.16503-1-jglisse@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jglisse@redhat.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

On Tue, Aug 08, 2017 at 06:08:20PM -0400, jglisse@redhat.com wrote:
> From: Jerome Glisse <jglisse@redhat.com>
> 
> Commit c7ab0d2fdc840266b39db94538f74207ec2afbf6 silently modified
> semantic of mmu_notifier_invalidate_page() this patch restore it
> to its previous semantic ie allowing to sleep inside invalidate_page()
> callback.
> 
> Signed-off-by: Jerome Glisse <jglisse@redhat.com>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

The issue in page_mkclean_one() was addressed recently by this:

http://lkml.kernel.org/r/20170804134928.l4klfcnqatni7vsc@black.fi.intel.com

(I think mmu_notifier_invalidate_range() it better in the situation, right?)

But I've missed try_to_unmap_one(). Could you prepare patch for this one?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
