Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id A7F286B005A
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 03:37:42 -0500 (EST)
Message-ID: <4F0E9C23.5050706@freescale.com>
Date: Thu, 12 Jan 2012 16:38:59 +0800
From: Huang Shijie <b32955@freescale.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm/compaction : do optimazition when the migration
 scanner gets no page
References: <1326347222-9980-1-git-send-email-b32955@freescale.com> <20120112080311.GA30634@barrios-desktop.redhat.com> <4F0E991C.7010009@freescale.com> <20120112083246.GC30634@barrios-desktop.redhat.com>
In-Reply-To: <20120112083246.GC30634@barrios-desktop.redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: akpm@linux-foundation.org, mgorman@suse.de, linux-mm@kvack.org

Hi,
> It depends on how we handle COMPACTBLOCKS.
> I think COMPACTBLOCK mean "trial" of compaction so although we can't isolate any page at all, we have to
> accout it with "trial of compaction".
> And in your patch, although nr_migrate is zero, you account it, too.
> And we have been accounted it until now.
ok, Wait for Mel Gorman for the FINAL explanation.

BR
Huang Shijie



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
