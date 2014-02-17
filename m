Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 5D2EA6B0031
	for <linux-mm@kvack.org>; Mon, 17 Feb 2014 12:18:02 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id kl14so15566598pab.29
        for <linux-mm@kvack.org>; Mon, 17 Feb 2014 09:18:02 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id xf4si15453122pab.133.2014.02.17.09.18.00
        for <linux-mm@kvack.org>;
        Mon, 17 Feb 2014 09:18:01 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <1392064866-11840-8-git-send-email-kirill.shutemov@linux.intel.com>
References: <1392064866-11840-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1392064866-11840-8-git-send-email-kirill.shutemov@linux.intel.com>
Subject: RE: [PATCH 7/8] mm: consolidate code to call vm_ops->page_mkwrite()
Content-Transfer-Encoding: 7bit
Message-Id: <20140217171756.EFF82E0090@blue.fi.intel.com>
Date: Mon, 17 Feb 2014 19:17:56 +0200 (EET)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, linux-mm@kvack.org

Hi Andrew,

I forgot to set VM_FAULT_LOCKED bit in do_page_mkwrite() return code, if
we lock the page in do_page_mkwrite(). It triggers deadlock, if
->page_mkwrite doesn't take page lock on its own.

Please replace orignal patch with the patch below.
