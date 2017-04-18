Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 215136B0390
	for <linux-mm@kvack.org>; Tue, 18 Apr 2017 17:01:27 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id 63so2778423pgh.3
        for <linux-mm@kvack.org>; Tue, 18 Apr 2017 14:01:27 -0700 (PDT)
Received: from mail-pf0-x230.google.com (mail-pf0-x230.google.com. [2607:f8b0:400e:c00::230])
        by mx.google.com with ESMTPS id d4si245593pfa.278.2017.04.18.14.01.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Apr 2017 14:01:26 -0700 (PDT)
Received: by mail-pf0-x230.google.com with SMTP id 194so2114139pfv.3
        for <linux-mm@kvack.org>; Tue, 18 Apr 2017 14:01:25 -0700 (PDT)
Date: Tue, 18 Apr 2017 14:01:24 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH V3] mm/madvise: Move up the behavior parameter
 validation
In-Reply-To: <20170418052844.24891-1-khandual@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.10.1704181401050.112481@chino.kir.corp.google.com>
References: <20170413092008.5437-1-khandual@linux.vnet.ibm.com> <20170418052844.24891-1-khandual@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, n-horiguchi@ah.jp.nec.com, akpm@linux-foundation.org

On Tue, 18 Apr 2017, Anshuman Khandual wrote:

> The madvise_behavior_valid() function should be called before
> acting upon the behavior parameter. Hence move up the function.
> This also includes MADV_SOFT_OFFLINE and MADV_HWPOISON options
> as valid behavior parameter for the system call madvise().
> 
> Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>

Acked-by: David Rientjes <rientjes@google.com>

Looks like this depends on existing patches in -mm.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
