Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id 594CC6B0035
	for <linux-mm@kvack.org>; Thu, 24 Apr 2014 14:18:20 -0400 (EDT)
Received: by mail-pb0-f52.google.com with SMTP id rq2so2247449pbb.11
        for <linux-mm@kvack.org>; Thu, 24 Apr 2014 11:18:20 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id qf5si3147329pac.375.2014.04.24.11.18.18
        for <linux-mm@kvack.org>;
        Thu, 24 Apr 2014 11:18:19 -0700 (PDT)
Date: Thu, 24 Apr 2014 11:18:17 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3 5/7] swap: Use bdev_read_page() / bdev_write_page()
Message-Id: <20140424111817.9cc62b2ff1e368c5cf27d262@linux-foundation.org>
In-Reply-To: <9fb0b4031b0fba312963a7cc21bf258d944cddcf.1397429628.git.matthew.r.wilcox@intel.com>
References: <cover.1397429628.git.matthew.r.wilcox@intel.com>
	<9fb0b4031b0fba312963a7cc21bf258d944cddcf.1397429628.git.matthew.r.wilcox@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, willy@linux.intel.com, Hugh Dickins <hughd@google.com>

On Sun, 13 Apr 2014 18:59:54 -0400 Matthew Wilcox <matthew.r.wilcox@intel.com> wrote:

>  mm/page_io.c | 23 +++++++++++++++++++++--
>  1 file changed, 21 insertions(+), 2 deletions(-)

Some changelog here would be nice.  What were the reasons for the
change?  Any observable performance changes?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
