Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9B73E4405AD
	for <linux-mm@kvack.org>; Wed, 15 Feb 2017 09:31:11 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id f5so180499339pgi.1
        for <linux-mm@kvack.org>; Wed, 15 Feb 2017 06:31:11 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 5si3899161plc.226.2017.02.15.06.31.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Feb 2017 06:31:10 -0800 (PST)
Date: Wed, 15 Feb 2017 06:31:10 -0800
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 1/3 staging-next] android: Collect statistics from
 lowmemorykiller
Message-ID: <20170215143110.GC11454@kroah.com>
References: <20170214160932.4988-1-peter.enderborg@sonymobile.com>
 <20170214165102.GE17335@kroah.com>
 <ef98ccbf-8e18-e55a-3af3-7ecec5fa60c5@sonymobile.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ef98ccbf-8e18-e55a-3af3-7ecec5fa60c5@sonymobile.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peter enderborg <peter.enderborg@sonymobile.com>
Cc: devel@driverdev.osuosl.org, riandrews@android.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, arve@android.com, torvalds@linux-foundation.org

On Wed, Feb 15, 2017 at 09:21:56AM +0100, peter enderborg wrote:
> On 02/14/2017 05:51 PM, Greg KH wrote:
> > On Tue, Feb 14, 2017 at 05:09:30PM +0100, peter.enderborg@sonymobile.com wrote:
> >> From: Peter Enderborg <peter.enderborg@sonymobile.com>
> >>
> >> This collects stats for shrinker calls and how much
> >> waste work we do within the lowmemorykiller.
> >>
> >> Signed-off-by: Peter Enderborg <peter.enderborg@sonymobile.com>
> > Wait, what changed from the previous versions of this patch?  Did you
> > take the review comments into consideration, or is this just a resend of
> > the original patches in a format that isn't corrupted?
> >
> > thanks,
> >
> > greg k-h
> 
> This is just a send with git-send-email that seems to work better. Nothing
> else than tab-spaces should be different. I would like to have some positive
> feedback from google/android before I start to send updated patches to the list.
> If google are ready for the userspace solution this patch set is pointless for
> upstream kernel.
> 
> Michal Hocko is very negative to hole thing, but we have addressed at least some
> issues he pointed out on the list in 2015. Is there any idea to continue?

If Michal rejected this solution, then I wouldn't be spending much time
on it at all.  Instead, I strongly suggest you try to do what he pointed
out should be done instead.  If that requires userspace help, great, try
that and see what happens.

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
