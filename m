Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id A253A6B0006
	for <linux-mm@kvack.org>; Tue,  2 Oct 2018 06:54:54 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id s24-v6so1429571plp.12
        for <linux-mm@kvack.org>; Tue, 02 Oct 2018 03:54:54 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id m4-v6si11444215pgn.113.2018.10.02.03.54.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Oct 2018 03:54:53 -0700 (PDT)
Date: Tue, 2 Oct 2018 13:54:50 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCHv3 1/6] mm/gup_benchmark: Time put_page
Message-ID: <20181002105450.2t6b4uprplhu2r4a@black.fi.intel.com>
References: <20180921223956.3485-1-keith.busch@intel.com>
 <20180921223956.3485-2-keith.busch@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180921223956.3485-2-keith.busch@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Keith Busch <keith.busch@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>

On Fri, Sep 21, 2018 at 10:39:51PM +0000, Keith Busch wrote:
> We'd like to measure time to unpin user pages, so this adds a second
> benchmark timer on put_page, separate from get_page.
> 
> Adding the field will breaks this ioctl ABI, but should be okay since
> this an in-tree kernel selftest.
> 
> Cc: Kirill Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Dave Hansen <dave.hansen@intel.com>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Signed-off-by: Keith Busch <keith.busch@intel.com>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov
