Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 304F46B0031
	for <linux-mm@kvack.org>; Thu, 21 Nov 2013 08:01:35 -0500 (EST)
Received: by mail-pd0-f174.google.com with SMTP id y13so4936255pdi.5
        for <linux-mm@kvack.org>; Thu, 21 Nov 2013 05:01:34 -0800 (PST)
Received: from psmtp.com ([74.125.245.204])
        by mx.google.com with SMTP id yd9si16924666pab.147.2013.11.21.05.01.32
        for <linux-mm@kvack.org>;
        Thu, 21 Nov 2013 05:01:33 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <1385038007-29666-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1385038007-29666-1-git-send-email-kirill.shutemov@linux.intel.com>
Subject: RE: [PATCH] x86, mm: do not leak page->ptl for pmd page tables
Content-Transfer-Encoding: 7bit
Message-Id: <20131121130006.E5A41E0090@blue.fi.intel.com>
Date: Thu, 21 Nov 2013 15:00:06 +0200 (EET)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Please, ignore. Sent wrong patch.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
