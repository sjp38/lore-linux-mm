Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f53.google.com (mail-wg0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id C7D0F6B0032
	for <linux-mm@kvack.org>; Fri, 19 Dec 2014 18:45:51 -0500 (EST)
Received: by mail-wg0-f53.google.com with SMTP id l18so2534928wgh.40
        for <linux-mm@kvack.org>; Fri, 19 Dec 2014 15:45:51 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id m10si5884703wie.93.2014.12.19.15.45.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Dec 2014 15:45:50 -0800 (PST)
Date: Fri, 19 Dec 2014 15:45:48 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] mm/zsmalloc: add statistics support
Message-Id: <20141219154548.3aa4cc02b3322f926aa4c1d6@linux-foundation.org>
In-Reply-To: <20141219233937.GA11975@blaptop>
References: <1418993719-14291-1-git-send-email-opensource.ganesh@gmail.com>
	<20141219143244.1e5fabad8b6733204486f5bc@linux-foundation.org>
	<20141219233937.GA11975@blaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Ganesh Mahendran <opensource.ganesh@gmail.com>, ngupta@vflare.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, 20 Dec 2014 08:39:37 +0900 Minchan Kim <minchan@kernel.org> wrote:

> Then, we should fix debugfs_create_dir can return errno to propagate the error
> to end user who can know it was failed ENOMEM or EEXIST.

Impractical.  Every caller of every debugfs interface will need to be
changed!

It's really irritating and dumb.  What we're supposed to do is to
optionally report the failure, then ignore it.  This patch appears to
be OK in that respect.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
