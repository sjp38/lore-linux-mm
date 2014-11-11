Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f182.google.com (mail-ie0-f182.google.com [209.85.223.182])
	by kanga.kvack.org (Postfix) with ESMTP id 0EBA26B011D
	for <linux-mm@kvack.org>; Tue, 11 Nov 2014 17:23:48 -0500 (EST)
Received: by mail-ie0-f182.google.com with SMTP id rd18so12566467iec.13
        for <linux-mm@kvack.org>; Tue, 11 Nov 2014 14:23:47 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id r40si33443865ioi.59.2014.11.11.14.23.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Nov 2014 14:23:46 -0800 (PST)
Date: Tue, 11 Nov 2014 14:23:44 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] mm: page_isolation: check pfn validity before
 access
Message-Id: <20141111142344.b4eb11c6e3c240d345fdd995@linux-foundation.org>
In-Reply-To: <000001cff998$ee0b31d0$ca219570$%yang@samsung.com>
References: <000001cff998$ee0b31d0$ca219570$%yang@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weijie Yang <weijie.yang@samsung.com>
Cc: kamezawa.hiroyu@jp.fujitsu.com, 'Minchan Kim' <minchan@kernel.org>, mgorman@suse.de, mina86@mina86.com, 'linux-kernel' <linux-kernel@vger.kernel.org>, 'Linux-MM' <linux-mm@kvack.org>, 'Weijie Yang' <weijie.yang.kh@gmail.com>

On Thu, 06 Nov 2014 16:08:02 +0800 Weijie Yang <weijie.yang@samsung.com> wrote:

> In the undo path of start_isolate_page_range(), we need to check
> the pfn validity before access its page, or it will trigger an
> addressing exception if there is hole in the zone.
> 

There is not enough information in the chagnelog for me to decide how
to handle the patch.  3.19?  3.18? 3.18+stable?

When fixing bugs, please remember to fully explain the end-user impact
of the bug.  Under what circumstances does it occur?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
