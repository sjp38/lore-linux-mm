Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 1753E6B0073
	for <linux-mm@kvack.org>; Thu, 11 Dec 2014 10:24:43 -0500 (EST)
Received: by mail-wi0-f179.google.com with SMTP id ex7so9039463wid.0
        for <linux-mm@kvack.org>; Thu, 11 Dec 2014 07:24:42 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id fv10si4481888wib.88.2014.12.11.07.24.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Dec 2014 07:24:42 -0800 (PST)
Date: Thu, 11 Dec 2014 10:24:23 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: add fields for compound destructor and order into
 struct page
Message-ID: <20141211152423.GA21603@phnom.home.cmpxchg.org>
References: <1418304027-154173-1-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1418304027-154173-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: akpm@linux-foundation.org, cl@linux.com, jmarchan@redhat.com, aneesh.kumar@linux.vnet.ibm.com, dave.hansen@intel.com, aarcange@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Dec 11, 2014 at 03:20:27PM +0200, Kirill A. Shutemov wrote:
> Currently, we use lru.next/lru.prev plus cast to access or set
> destructor and order of compound page.
> 
> Let's replace it with explicit fields in struct page.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
