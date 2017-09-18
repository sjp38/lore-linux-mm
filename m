Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4ED8A6B0033
	for <linux-mm@kvack.org>; Mon, 18 Sep 2017 10:36:28 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id 93so1641040iol.2
        for <linux-mm@kvack.org>; Mon, 18 Sep 2017 07:36:28 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t141si4569811oie.1.2017.09.18.07.36.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Sep 2017 07:36:27 -0700 (PDT)
Message-ID: <1505745385.21121.53.camel@redhat.com>
Subject: Re: [PATCH] mm: Fix typo in VM_MPX definition
From: Rik van Riel <riel@redhat.com>
Date: Mon, 18 Sep 2017 10:36:25 -0400
In-Reply-To: <20170918140253.36856-1-kirill.shutemov@linux.intel.com>
References: <20170918140253.36856-1-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@intel.com>

On Mon, 2017-09-18 at 17:02 +0300, Kirill A. Shutemov wrote:
> There's typo in recent change of VM_MPX definition. We want it to be
> VM_HIGH_ARCH_4, not VM_HIGH_ARCH_BIT_4.

Ugh, indeed! Good catch!

> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Fixes: df3735c5b40f ("x86,mpx: make mpx depend on x86-64 to free up
> VMA flag")
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Dave Hansen <dave.hansen@intel.com>

Reviewed-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
