Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3B5D86B0038
	for <linux-mm@kvack.org>; Tue, 16 Jun 2015 17:29:37 -0400 (EDT)
Received: by pacgb13 with SMTP id gb13so20263161pac.1
        for <linux-mm@kvack.org>; Tue, 16 Jun 2015 14:29:37 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id ps1si2946802pdb.215.2015.06.16.14.29.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jun 2015 14:29:36 -0700 (PDT)
Date: Tue, 16 Jun 2015 14:29:35 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4] pagemap: switch to the new format and do some
 cleanup
Message-Id: <20150616142935.b8f679650e35534e75806399@linux-foundation.org>
In-Reply-To: <20150615055649.4485.92087.stgit@zurg>
References: <20150609200021.21971.13598.stgit@zurg>
	<20150615055649.4485.92087.stgit@zurg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: linux-mm@kvack.org, Mark Williamson <mwilliamson@undo-software.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>

On Mon, 15 Jun 2015 08:56:49 +0300 Konstantin Khlebnikov <koct9i@gmail.com> wrote:

> This patch removes page-shift bits (scheduled to remove since 3.11) and
> completes migration to the new bit layout. Also it cleans messy macro.

hm, I can't find any kernel version to which this patch comes close to
applying.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
