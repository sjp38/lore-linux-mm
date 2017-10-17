Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id EF3F56B0038
	for <linux-mm@kvack.org>; Tue, 17 Oct 2017 07:26:35 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id c42so680588wrc.13
        for <linux-mm@kvack.org>; Tue, 17 Oct 2017 04:26:35 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d8sor4848112edk.17.2017.10.17.04.26.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 17 Oct 2017 04:26:34 -0700 (PDT)
Date: Tue, 17 Oct 2017 14:26:32 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm/rmap: remove redundant variable cend
Message-ID: <20171017112632.xsx4ejefkteybem3@node.shutemov.name>
References: <20171011174942.1372-1-colin.king@canonical.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171011174942.1372-1-colin.king@canonical.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Colin King <colin.king@canonical.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Oct 11, 2017 at 06:49:42PM +0100, Colin King wrote:
> From: Colin Ian King <colin.king@canonical.com>
> 
> Variable cend is set but never read, hence it is redundant and can be
> removed.
> 
> Cleans up clang build warning: Value stored to 'cend' is never read
> 
> Fixes: 369ea8242c0f ("mm/rmap: update to new mmu_notifier semantic v2")

I'm not sure if should consider warning fix as a fix. :)

> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
