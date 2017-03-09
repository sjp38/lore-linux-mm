Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id E04A72808B4
	for <linux-mm@kvack.org>; Thu,  9 Mar 2017 04:30:38 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id y17so102697149pgh.2
        for <linux-mm@kvack.org>; Thu, 09 Mar 2017 01:30:38 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id o5si5918210pgg.169.2017.03.09.01.30.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Mar 2017 01:30:38 -0800 (PST)
Date: Thu, 9 Mar 2017 10:30:28 +0100
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] staging, android: remove lowmemory killer from the tree
Message-ID: <20170309093028.GA12156@kroah.com>
References: <20170222120121.12601-1-mhocko@kernel.org>
 <20170309091513.GA11598@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170309091513.GA11598@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Arve =?iso-8859-1?B?SGr4bm5lduVn?= <arve@android.com>, Riley Andrews <riandrews@android.com>, devel@driverdev.osuosl.org, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, John Stultz <john.stultz@linaro.org>, Todd Kjos <tkjos@google.com>, Martijn Coenen <maco@google.com>, Tim Murray <timmurray@google.com>, peter enderborg <peter.enderborg@sonymobile.com>, Rom Lemarchand <romlem@google.com>

On Thu, Mar 09, 2017 at 10:15:13AM +0100, Michal Hocko wrote:
> Greg, do you see any obstacle to have this merged. The discussion so far
> shown that a) vendors are not using the code as is b) there seems to be
> an agreement that something else than we have in the kernel is really
> needed.

Well, some vendors are using the code as-is, just not Sony...

I think the ideas that Tim wrote about is the best way forward for this.
I'd prefer to leave the code in the kernel until that solution is
integrated, as dropping support entirely isn't very nice.

But, given that almost no Android system is running mainline at the
moment, I will queue this patch up for 4.12-rc1, which will give the
Google people a bit more of an incentive to get their solution
implemented and working and merged :)

Sound reasonable?  I haven't started to go through my patch queue for
4.12-rc1 stuff just yet, still digging through it for 4.11-final things
at the moment.  Give me a week or so to catch up.

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
