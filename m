Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 985B86B0031
	for <linux-mm@kvack.org>; Tue,  8 Oct 2013 16:46:15 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id kq14so9416685pab.12
        for <linux-mm@kvack.org>; Tue, 08 Oct 2013 13:46:15 -0700 (PDT)
Received: from /spool/local
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjennings@medulla.variantweb.net>;
	Tue, 8 Oct 2013 14:46:12 -0600
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 60F611FF001B
	for <linux-mm@kvack.org>; Tue,  8 Oct 2013 14:46:01 -0600 (MDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r98KkAEO230416
	for <linux-mm@kvack.org>; Tue, 8 Oct 2013 14:46:10 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r98Kk60I028939
	for <linux-mm@kvack.org>; Tue, 8 Oct 2013 14:46:09 -0600
Date: Tue, 8 Oct 2013 15:46:03 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: Re: [PATCH v3 2/6] zbud: make freechunks a block local variable
Message-ID: <20131008204603.GB8798@medulla.variantweb.net>
References: <1381238980-2491-1-git-send-email-k.kozlowski@samsung.com>
 <1381238980-2491-3-git-send-email-k.kozlowski@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1381238980-2491-3-git-send-email-k.kozlowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Bob Liu <bob.liu@oracle.com>, Mel Gorman <mgorman@suse.de>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Tomasz Stanislawski <t.stanislaws@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Dave Hansen <dave.hansen@intel.com>, Minchan Kim <minchan@kernel.org>

On Tue, Oct 08, 2013 at 03:29:36PM +0200, Krzysztof Kozlowski wrote:
> Move freechunks variable in zbud_free() and zbud_alloc() to block-level
> scope (from function scope).
> 
> Signed-off-by: Krzysztof Kozlowski <k.kozlowski@samsung.com>

Doesn't make a functional difference but does self-document the
narrow scope where the variable is used so:

Acked-by: Seth Jennings <sjenning@linux.vnet.ibm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
