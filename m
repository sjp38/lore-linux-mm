Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 746C844059E
	for <linux-mm@kvack.org>; Wed, 15 Feb 2017 09:29:15 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 201so183055778pfw.5
        for <linux-mm@kvack.org>; Wed, 15 Feb 2017 06:29:15 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 3si2467044plp.314.2017.02.15.06.29.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Feb 2017 06:29:14 -0800 (PST)
Date: Wed, 15 Feb 2017 06:29:14 -0800
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 1/3 staging-next] android: Collect statistics from
 lowmemorykiller
Message-ID: <20170215142914.GB11454@kroah.com>
References: <20170214160932.4988-1-peter.enderborg@sonymobile.com>
 <20170214165015.GD17335@kroah.com>
 <cd0b0197-4d5a-bef3-b4a4-69f5ad12f01c@sonymobile.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cd0b0197-4d5a-bef3-b4a4-69f5ad12f01c@sonymobile.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peter enderborg <peter.enderborg@sonymobile.com>
Cc: devel@driverdev.osuosl.org, riandrews@android.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, arve@android.com, torvalds@linux-foundation.org

On Wed, Feb 15, 2017 at 09:22:10AM +0100, peter enderborg wrote:
> On 02/14/2017 05:50 PM, Greg KH wrote:
> > On Tue, Feb 14, 2017 at 05:09:30PM +0100, peter.enderborg@sonymobile.com wrote:
> >> From: Peter Enderborg <peter.enderborg@sonymobile.com>
> >>
> >> This collects stats for shrinker calls and how much
> >> waste work we do within the lowmemorykiller.
> >>
> >> Signed-off-by: Peter Enderborg <peter.enderborg@sonymobile.com>
> >> ---
> >>  drivers/staging/android/Kconfig                 | 11 ++++
> >>  drivers/staging/android/Makefile                |  1 +
> >>  drivers/staging/android/lowmemorykiller.c       |  9 ++-
> >>  drivers/staging/android/lowmemorykiller_stats.c | 85 +++++++++++++++++++++++++
> >>  drivers/staging/android/lowmemorykiller_stats.h | 29 +++++++++
> >>  5 files changed, 134 insertions(+), 1 deletion(-)
> >>  create mode 100644 drivers/staging/android/lowmemorykiller_stats.c
> >>  create mode 100644 drivers/staging/android/lowmemorykiller_stats.h
> >>
> >> diff --git a/drivers/staging/android/Kconfig b/drivers/staging/android/Kconfig
> >> index 6c00d6f..96e86c7 100644
> >> --- a/drivers/staging/android/Kconfig
> >> +++ b/drivers/staging/android/Kconfig
> >> @@ -24,6 +24,17 @@ config ANDROID_LOW_MEMORY_KILLER
> >>  	  scripts (/init.rc), and it defines priority values with minimum free memory size
> >>  	  for each priority.
> >>  
> >> +config ANDROID_LOW_MEMORY_KILLER_STATS
> >> +	bool "Android Low Memory Killer: collect statistics"
> >> +	depends on ANDROID_LOW_MEMORY_KILLER
> >> +	default n
> >> +	help
> >> +	  Create a file in /proc/lmkstats that includes
> >> +	  collected statistics about kills, scans and counts
> >> +	  and  interaction with the shrinker. Its content
> >> +	  will be different depeding on lmk implementation used.
> > Ick, no new /proc files please, this isn't a "process" value.  What's
> > wrong with debugfs?
> This is intended for android. Android users are very limited in their access
> to linux part of the system on commercial models and lmk activity has a bad impact on the performance
> of the device. Even the application developers has not much access so it seems to be fair to give
> the users the information about why there is a problem.

Why would you want to give "all users" this information at all?  This is
a debugging tool, your debugging userspace framework can use whatever
interface you create to access it (i.e. debugfs).

Again, do not add debugging stuff to /proc/ that's not ok, sorry.

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
