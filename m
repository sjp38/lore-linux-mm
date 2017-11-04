Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 27E706B0033
	for <linux-mm@kvack.org>; Sat,  4 Nov 2017 07:41:08 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id l8so1569745wmg.7
        for <linux-mm@kvack.org>; Sat, 04 Nov 2017 04:41:08 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id o13si3743500wmf.223.2017.11.04.04.41.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 04 Nov 2017 04:41:07 -0700 (PDT)
Date: Sat, 4 Nov 2017 12:41:18 +0100
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] writeback: remove the unused function parameter
Message-ID: <20171104114118.GA10809@kroah.com>
References: <1509680672-10004-1-git-send-email-wanglong19@meituan.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1509680672-10004-1-git-send-email-wanglong19@meituan.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wang Long <wanglong19@meituan.com>
Cc: jack@suse.cz, tj@kernel.org, akpm@linux-foundation.org, axboe@fb.com, nborisov@suse.com, hannes@cmpxchg.org, vdavydov.dev@gmail.com, jlayton@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Nov 02, 2017 at 11:44:32PM -0400, Wang Long wrote:
> Signed-off-by: Wang Long <wanglong19@meituan.com>
> ---

I know I don't take patches without any changelog text :(

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
