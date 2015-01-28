Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f180.google.com (mail-ob0-f180.google.com [209.85.214.180])
	by kanga.kvack.org (Postfix) with ESMTP id CC6D96B0038
	for <linux-mm@kvack.org>; Wed, 28 Jan 2015 12:06:06 -0500 (EST)
Received: by mail-ob0-f180.google.com with SMTP id vb8so2526762obc.11
        for <linux-mm@kvack.org>; Wed, 28 Jan 2015 09:06:06 -0800 (PST)
Received: from bh-25.webhostbox.net (bh-25.webhostbox.net. [208.91.199.152])
        by mx.google.com with ESMTPS id l127si2488829oif.68.2015.01.28.09.06.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 28 Jan 2015 09:06:05 -0800 (PST)
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YGW45-001IUj-P0
	for linux-mm@kvack.org; Wed, 28 Jan 2015 17:06:05 +0000
Date: Wed, 28 Jan 2015 09:06:00 -0800
From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH 0/4] Introduce <linux/mm_struct.h>
Message-ID: <20150128170600.GA28310@roeck-us.net>
References: <1422451064-109023-1-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1422451064-109023-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jan 28, 2015 at 03:17:40PM +0200, Kirill A. Shutemov wrote:
> This patchset moves definition of mm_struct into separate header file.
> It allows to get rid of nr_pmds if PMD page table level is folded.
> We cannot do it with current mm_types.h because we need
> __PAGETABLE_PMD_FOLDED from <asm/pgtable.h> which creates circular
> dependencies.
> 
> I've done few build tests and looks like it works, but I expect breakage
> on some configuration. Please test.
> 
I applied your patches on top of the current mmotm and pushed into 
my 'testing' branch. I'll send out test results after the test cycle
is complete.

Guenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
