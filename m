Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 3E32D6B0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2013 16:44:31 -0500 (EST)
Received: by mail-ob0-f176.google.com with SMTP id v19so7069163obq.21
        for <linux-mm@kvack.org>; Tue, 19 Feb 2013 13:44:30 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20130219113012.GP4365@suse.de>
References: <CAHGf_=rb0t4gbm0Egw9D3RUuwbgL8U6hPwBwS46C27mgAvJp0g@mail.gmail.com>
 <20130218145018.GJ4365@suse.de> <5122E8C0.4020404@gmail.com> <20130219113012.GP4365@suse.de>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Tue, 19 Feb 2013 16:44:08 -0500
Message-ID: <CAHGf_=qJrjU27J2z7mVHcRMGYGSdRZeKjALZYm_qgVFMgF6r_A@mail.gmail.com>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC][ATTEND] a few topics I'd like to discuss
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: lsf-pc@lists.linux-foundation.org, "linux-mm@kvack.org" <linux-mm@kvack.org>

> It's disabled by default simply because at the time the pages were not
> movable at all. They now should be movable with some additional work and
> potentially the default could change after that or be removed entirely.

Got it. I also found several corner case in current code and I'm
interesting to fix it.
Thank you!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
