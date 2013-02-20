Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 1109E6B0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2013 05:44:24 -0500 (EST)
Received: by mail-vb0-f49.google.com with SMTP id s24so4826847vbi.8
        for <linux-mm@kvack.org>; Wed, 20 Feb 2013 02:44:24 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CANZA+xgRWQe2fm8Gok4SxRXEeRU5CztijG4HKNeTDFQfSgHPPw@mail.gmail.com>
References: <CANZA+xgRWQe2fm8Gok4SxRXEeRU5CztijG4HKNeTDFQfSgHPPw@mail.gmail.com>
Date: Wed, 20 Feb 2013 18:44:23 +0800
Message-ID: <CANZA+xgXcwQe8S3+HfaF4QRCTB-XoWS0pvtO4CJT0CT0MMQZqQ@mail.gmail.com>
Subject: What does the PG_swapbacked of page flags actually mean?
From: common An <xx.kernel@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org

PG_swapbacked is a bit for page->flags.

In kernel code, its comment is "page is backed by RAM/swap". But I couldn't
understand it.
1. Does the RAM mean DRAM? How page is backed by RAM?
2. When the page is page-out to swap file, the bit PG_swapbacked will be set
to demonstrate this page is backed by swap. Is it right?
3. In general, when will call SetPageSwapBacked() to set the bit?

Could anybody kindly explain for me?

Thanks very much.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
