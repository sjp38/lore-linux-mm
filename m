Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id AF43782F64
	for <linux-mm@kvack.org>; Fri,  6 Nov 2015 01:32:19 -0500 (EST)
Received: by igpw7 with SMTP id w7so26649954igp.1
        for <linux-mm@kvack.org>; Thu, 05 Nov 2015 22:32:19 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id t12si1469910igd.27.2015.11.05.22.32.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Nov 2015 22:32:18 -0800 (PST)
Subject: Re: [PATCH v1] mm: hwpoison: adjust for new thp refcounting
References: <1446790309-15683-1-git-send-email-n-horiguchi@ah.jp.nec.com>
From: Sasha Levin <sasha.levin@oracle.com>
Message-ID: <563C4955.3000300@oracle.com>
Date: Fri, 6 Nov 2015 01:31:49 -0500
MIME-Version: 1.0
In-Reply-To: <1446790309-15683-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Wanpeng Li <wanpeng.li@hotmail.com>, Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On 11/06/2015 01:11 AM, Naoya Horiguchi wrote:
> In the new refcounting, we no longer use tail->_mapcount to keep tail's
> refcount, and thereby we can simplify get_hwpoison_page() and remove
> put_hwpoison_page() (by replacing with put_page()).

This is confusing for the reader (and some static analysis tools): this adds
put_page()s without corresponding get_page()s.

Could we instead macro put_hwpoison_page() as put_page() for the sake of readability?


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
