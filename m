Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 7C6F96B007E
	for <linux-mm@kvack.org>; Mon,  2 Apr 2012 10:42:32 -0400 (EDT)
Received: by iajr24 with SMTP id r24so5661098iaj.14
        for <linux-mm@kvack.org>; Mon, 02 Apr 2012 07:42:31 -0700 (PDT)
Date: Mon, 2 Apr 2012 07:41:56 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: swap on eMMC and other flash
In-Reply-To: <201204021145.43222.arnd@arndb.de>
Message-ID: <alpine.LSU.2.00.1204020734560.1847@eggly.anvils>
References: <201203301744.16762.arnd@arndb.de> <201203301850.22784.arnd@arndb.de> <alpine.LSU.2.00.1203311230490.10965@eggly.anvils> <201204021145.43222.arnd@arndb.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: linaro-kernel@lists.linaro.org, Rik van Riel <riel@redhat.com>, "linux-mmc@vger.kernel.org" <linux-mmc@vger.kernel.org>, Alex Lemberg <alex.lemberg@sandisk.com>, linux-kernel@vger.kernel.org, "Luca Porzio (lporzio)" <lporzio@micron.com>, linux-mm@kvack.org, Hyojin Jeong <syr.jeong@samsung.com>, kernel-team@android.com, Yejin Moon <yejin.moon@samsung.com>

On Mon, 2 Apr 2012, Arnd Bergmann wrote:
> 
> Another option would be batched discard as we do it for file systems:
> occasionally stop writing to swap space and scanning for areas that
> have become available since the last discard, then send discard
> commands for those.

I'm not sure whether you've missed "swapon --discard", which switches
on discard_swap_cluster() just before we allocate from a new cluster;
or whether you're musing that it's no use to you because you want to
repurpose the swap cluster to match erase block: I'm mentioning it in
case you missed that it's already there (but few use it, since even
done at that scale it's often more trouble than it's worth).

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
