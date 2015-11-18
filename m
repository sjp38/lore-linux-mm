Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 256926B0272
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 09:17:24 -0500 (EST)
Received: by wmww144 with SMTP id w144so74077459wmw.0
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 06:17:23 -0800 (PST)
Received: from mail-wm0-x22c.google.com (mail-wm0-x22c.google.com. [2a00:1450:400c:c09::22c])
        by mx.google.com with ESMTPS id t6si5049762wmf.88.2015.11.18.06.17.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Nov 2015 06:17:22 -0800 (PST)
Received: by wmww144 with SMTP id w144so74076564wmw.0
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 06:17:22 -0800 (PST)
Date: Wed, 18 Nov 2015 16:17:20 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm, thp: use list_first_entry_or_null()
Message-ID: <20151118141720.GA24878@node.shutemov.name>
References: <007bfe4833c1e47bd313de6a1be65d61aa7e36e2.1447854574.git.geliangtang@163.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <007bfe4833c1e47bd313de6a1be65d61aa7e36e2.1447854574.git.geliangtang@163.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geliang Tang <geliangtang@163.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Vineet Gupta <vgupta@synopsys.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Nov 18, 2015 at 09:52:29PM +0800, Geliang Tang wrote:
> Simplify the code with list_first_entry_or_null().
> 
> Signed-off-by: Geliang Tang <geliangtang@163.com>

Looks good to me.

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
