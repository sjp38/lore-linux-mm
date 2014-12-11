Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f177.google.com (mail-qc0-f177.google.com [209.85.216.177])
	by kanga.kvack.org (Postfix) with ESMTP id 059436B0073
	for <linux-mm@kvack.org>; Thu, 11 Dec 2014 10:03:36 -0500 (EST)
Received: by mail-qc0-f177.google.com with SMTP id x3so3922002qcv.22
        for <linux-mm@kvack.org>; Thu, 11 Dec 2014 07:03:35 -0800 (PST)
Received: from resqmta-ch2-05v.sys.comcast.net (resqmta-ch2-05v.sys.comcast.net. [2001:558:fe21:29:69:252:207:37])
        by mx.google.com with ESMTPS id n16si1515785qar.14.2014.12.11.07.03.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 11 Dec 2014 07:03:35 -0800 (PST)
Date: Thu, 11 Dec 2014 09:03:33 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm: add fields for compound destructor and order into
 struct page
In-Reply-To: <1418304027-154173-1-git-send-email-kirill.shutemov@linux.intel.com>
Message-ID: <alpine.DEB.2.11.1412110902170.28416@gentwo.org>
References: <1418304027-154173-1-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: akpm@linux-foundation.org, jmarchan@redhat.com, aneesh.kumar@linux.vnet.ibm.com, dave.hansen@intel.com, aarcange@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 11 Dec 2014, Kirill A. Shutemov wrote:

> Currently, we use lru.next/lru.prev plus cast to access or set
> destructor and order of compound page.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
