Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8F42D6B03BB
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 11:51:02 -0500 (EST)
Received: by mail-vk0-f69.google.com with SMTP id 78so92674441vkj.2
        for <linux-mm@kvack.org>; Tue, 14 Feb 2017 08:51:02 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id c16si957267pli.236.2017.02.14.08.51.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Feb 2017 08:51:01 -0800 (PST)
Date: Tue, 14 Feb 2017 08:51:02 -0800
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 1/3 staging-next] android: Collect statistics from
 lowmemorykiller
Message-ID: <20170214165102.GE17335@kroah.com>
References: <20170214160932.4988-1-peter.enderborg@sonymobile.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170214160932.4988-1-peter.enderborg@sonymobile.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peter.enderborg@sonymobile.com
Cc: devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, arve@android.com, riandrews@android.com, torvalds@linux-foundation.org, linux-mm@kvack.org

On Tue, Feb 14, 2017 at 05:09:30PM +0100, peter.enderborg@sonymobile.com wrote:
> From: Peter Enderborg <peter.enderborg@sonymobile.com>
> 
> This collects stats for shrinker calls and how much
> waste work we do within the lowmemorykiller.
> 
> Signed-off-by: Peter Enderborg <peter.enderborg@sonymobile.com>

Wait, what changed from the previous versions of this patch?  Did you
take the review comments into consideration, or is this just a resend of
the original patches in a format that isn't corrupted?

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
