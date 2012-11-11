Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id DD2146B002B
	for <linux-mm@kvack.org>; Sun, 11 Nov 2012 07:41:21 -0500 (EST)
Received: from mail-ea0-f169.google.com ([209.85.215.169])
	by youngberry.canonical.com with esmtpsa (TLS1.0:RSA_ARCFOUR_SHA1:16)
	(Exim 4.71)
	(envelope-from <ming.lei@canonical.com>)
	id 1TXWqm-00066j-R6
	for linux-mm@kvack.org; Sun, 11 Nov 2012 12:41:20 +0000
Received: by mail-ea0-f169.google.com with SMTP id k11so2519282eaa.14
        for <linux-mm@kvack.org>; Sun, 11 Nov 2012 04:41:20 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1352637278-19968-2-git-send-email-ming.lei@canonical.com>
References: <1352637278-19968-1-git-send-email-ming.lei@canonical.com>
	<1352637278-19968-2-git-send-email-ming.lei@canonical.com>
Date: Sun, 11 Nov 2012 20:41:20 +0800
Message-ID: <CACVXFVPMd11NPXLE=Ttj75ScMGHLvAYcYMjAyCmRvU3KZauqzg@mail.gmail.com>
Subject: Re: [PATCH v5 1/6] mm: teach mm by current context info to not do I/O
 during memory allocation
From: Ming Lei <ming.lei@canonical.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Alan Stern <stern@rowland.harvard.edu>, Oliver Neukum <oneukum@suse.de>, Minchan Kim <minchan@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Jens Axboe <axboe@kernel.dk>, "David S. Miller" <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org, linux-usb@vger.kernel.org, linux-pm@vger.kernel.org, linux-mm@kvack.org, Ming Lei <ming.lei@canonical.com>, Jiri Kosina <jiri.kosina@suse.com>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>

On Sun, Nov 11, 2012 at 8:34 PM, Ming Lei <ming.lei@canonical.com> wrote:
> +/* GFP_NOIO isn't allowed if PF_MEMALLOC_NOIO is set in current->flags */
> +static inline gfp_t memalloc_noio_flags(gfp_t flags)
> +{
> +       if (unlikely(current->flags & PF_MEMALLOC_NOIO))
> +               flags &= ~GFP_NOIO;
> +       return flags;

Sorry, the above is wrong, and GFP_IO should be cleared, and I will
resend this one.


Thanks,
--
Ming Lei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
