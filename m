Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 1EEE46B005C
	for <linux-mm@kvack.org>; Tue, 12 Jun 2012 12:03:28 -0400 (EDT)
Received: by yhr47 with SMTP id 47so4613682yhr.14
        for <linux-mm@kvack.org>; Tue, 12 Jun 2012 09:03:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4FD6ECE2.6070901@kernel.org>
References: <1338575387-26972-1-git-send-email-john.stultz@linaro.org>
 <1338575387-26972-4-git-send-email-john.stultz@linaro.org>
 <4FC9235F.5000402@gmail.com> <4FC92E30.4000906@linaro.org>
 <4FC9360B.4020401@gmail.com> <4FC937AD.8040201@linaro.org>
 <4FC9438B.1000403@gmail.com> <4FC94F61.20305@linaro.org> <4FCFB4F6.6070308@gmail.com>
 <4FCFEE36.3010902@linaro.org> <CAO6Zf6D++8hOz19BmUwQ8iwbQknQRNsF4npP4r-830j04vbj=g@mail.gmail.com>
 <4FD13C30.2030401@linux.vnet.ibm.com> <4FD16B6E.8000307@linaro.org>
 <4FD1848B.7040102@gmail.com> <4FD2C6C5.1070900@linaro.org> <4FD6ECE2.6070901@kernel.org>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Tue, 12 Jun 2012 12:03:04 -0400
Message-ID: <CAHGf_=oTC6LGd-5=aGYM4rj+3AAVPr9Zk8cT_FXguVhSVgKWnQ@mail.gmail.com>
Subject: Re: [PATCH 3/3] [RFC] tmpfs: Add FALLOC_FL_MARK_VOLATILE/UNMARK_VOLATILE
 handlers
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: John Stultz <john.stultz@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Taras Glek <tgek@mozilla.com>, Mike Hommey <mh@glandium.org>, Jan Kara <jack@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>

> Off-topic:
> But I'm not sure because I might try to make new easy-reclaimable LRU list for low memory notification.
> That LRU list would contain non-mapped clean cache page and volatile pages if I decide adding it.
> Both pages has a common characteristic that recreating page is less costly.
> It's true for eMMC/SSD like device, at least.

+1.

I like L2 inactive list.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
