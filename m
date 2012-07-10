Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 2DA7A6B006C
	for <linux-mm@kvack.org>; Tue, 10 Jul 2012 01:35:29 -0400 (EDT)
Received: by lbjn8 with SMTP id n8so21856370lbj.14
        for <linux-mm@kvack.org>; Mon, 09 Jul 2012 22:35:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120709142936.GB17314@barrios>
References: <1340783514-8150-1-git-send-email-minchan@kernel.org>
	<1340783514-8150-3-git-send-email-minchan@kernel.org>
	<CAEtiSavGmp=V37jxmLm2eQyRP3F08KotF9Dma5JCn7uaJbPo+w@mail.gmail.com>
	<20120709142936.GB17314@barrios>
Date: Tue, 10 Jul 2012 11:05:26 +0530
Message-ID: <CAEtiSau+=dUfqBTjuJbdjNsnh_-cay6HCSuZKpZ=mVR6-ouVTQ@mail.gmail.com>
Subject: Re: [PATCH 2/2 v2] memory-hotplug: fix kswapd looping forever problem
From: Aaditya Kumar <aaditya.kumar.30@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: akpm@linux-foundation.org, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, tim.bird@am.sony.com, frank.rowand@am.sony.com, takuzo.ohara@ap.sony.com, kan.iibuchi@jp.sony.com, aaditya.kumar@ap.sony.com

On Mon, Jul 9, 2012 at 7:59 PM, Minchan Kim <minchan@kernel.org> wrote:

Hello Minchan,

> May I add your tested-by in next spin which will include automatic type conversion
> problem ?

Yeah sure.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
