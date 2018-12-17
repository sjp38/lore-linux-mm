Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 734698E0001
	for <linux-mm@kvack.org>; Mon, 17 Dec 2018 07:36:53 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id o23so9093748pll.0
        for <linux-mm@kvack.org>; Mon, 17 Dec 2018 04:36:53 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w5sor19186166plz.13.2018.12.17.04.36.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 17 Dec 2018 04:36:52 -0800 (PST)
Date: Mon, 17 Dec 2018 15:36:45 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: Remove __hugepage_set_anon_rmap()
Message-ID: <20181217123645.vblqlndn7qh5co5l@kshutemo-mobl1>
References: <154504875359.30235.6237926369392564851.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <154504875359.30235.6237926369392564851.stgit@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, mike.kravetz@oracle.com, jglisse@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Dec 17, 2018 at 03:13:51PM +0300, Kirill Tkhai wrote:
> This function is identical to __page_set_anon_rmap()
> since the time, when it was introduced (8 years ago).
> The patch removes the function, and makes its users
> to use __page_set_anon_rmap() instead.
> 
> Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov
