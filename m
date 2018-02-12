Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id D0DC26B0012
	for <linux-mm@kvack.org>; Mon, 12 Feb 2018 09:07:49 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id 17so2502979wma.1
        for <linux-mm@kvack.org>; Mon, 12 Feb 2018 06:07:49 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id r46sor4062006eda.57.2018.02.12.06.07.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 12 Feb 2018 06:07:48 -0800 (PST)
Date: Mon, 12 Feb 2018 17:07:46 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v3 1/2] mm/page_ref: use atomic_set_release in
 page_ref_unfreeze
Message-ID: <20180212140746.3gojy7ybiq763pj3@node.shutemov.name>
References: <4f64569f-b8ce-54f8-33d9-0e67216bb54c@yandex-team.ru>
 <151844393004.210639.4672319312617954272.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <151844393004.210639.4672319312617954272.stgit@buzz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.com>, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Nicholas Piggin <npiggin@gmail.com>

On Mon, Feb 12, 2018 at 04:58:50PM +0300, Konstantin Khlebnikov wrote:
> page_ref_unfreeze() has exactly that semantic. No functional
> changes: just minus one barrier and proper handling of PPro errata.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
