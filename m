Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f181.google.com (mail-ie0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id 605226B00D7
	for <linux-mm@kvack.org>; Thu, 13 Nov 2014 20:51:52 -0500 (EST)
Received: by mail-ie0-f181.google.com with SMTP id rp18so16467119iec.26
        for <linux-mm@kvack.org>; Thu, 13 Nov 2014 17:51:52 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id b189si42024660ioe.1.2014.11.13.17.51.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Nov 2014 17:51:50 -0800 (PST)
Date: Thu, 13 Nov 2014 17:52:19 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v17 0/7] MADV_FREE support
Message-Id: <20141113175219.d9290ffe.akpm@linux-foundation.org>
In-Reply-To: <20141113225809.GA8997@bbox>
References: <1413799924-17946-1-git-send-email-minchan@kernel.org>
	<20141113225809.GA8997@bbox>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Jason Evans <je@fb.com>, zhangyanfei@cn.fujitsu.com, "Kirill A. Shutemov" <kirill@shutemov.name>

On Fri, 14 Nov 2014 07:58:09 +0900 Minchan Kim <minchan@kernel.org> wrote:

> It seems I have waited your review for a long time.
> What should I do to take your time slot?

I'm being terrible, sorry.

I'll merge the patches into -mm next week so at least they get some
external testing while I get my ass into gear.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
