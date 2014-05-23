Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id 740176B0036
	for <linux-mm@kvack.org>; Fri, 23 May 2014 14:53:35 -0400 (EDT)
Received: by mail-pb0-f50.google.com with SMTP id ma3so4542620pbc.37
        for <linux-mm@kvack.org>; Fri, 23 May 2014 11:53:35 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id un1si5188167pac.13.2014.05.23.11.53.34
        for <linux-mm@kvack.org>;
        Fri, 23 May 2014 11:53:34 -0700 (PDT)
Date: Sat, 24 May 2014 03:47:23 +0900
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] staging: ion: WARN when the handle kmap_cnt is going to
 wrap around
Message-ID: <20140523184723.GA5355@kroah.com>
References: <1400806281-32716-1-git-send-email-mitchelh@codeaurora.org>
 <CAMbhsRQpR-Q=kgr92ezauBj200_2cfnsXHkk+3oPD51ZKD=4RQ@mail.gmail.com>
 <vnkw61kws5rg.fsf@mitchelh-linux.qualcomm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <vnkw61kws5rg.fsf@mitchelh-linux.qualcomm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mitchel Humpherys <mitchelh@codeaurora.org>
Cc: Colin Cross <ccross@android.com>, devel@driverdev.osuosl.org, Linux-MM <linux-mm@kvack.org>, John Stultz <john.stultz@linaro.org>, Android Kernel Team <kernel-team@android.com>, lkml <linux-kernel@vger.kernel.org>

On Fri, May 23, 2014 at 11:34:59AM -0700, Mitchel Humpherys wrote:
> ++greg-kh and devel@driverdev.osuosl.org
> (my bad for missing you the first time around)

What can I do with this?  Please send patches to me in a format that I
can actually apply them in...

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
