Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id D33EC8D003A
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 14:59:19 -0400 (EDT)
Date: Tue, 15 Mar 2011 19:59:13 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: 2.6.38-rc echo 3 > /proc/sys/vm/drop_caches repairs mplayer
 distortions
Message-ID: <20110315185913.GH2140@cmpxchg.org>
References: <4D7E89E7.3080505@xmsnet.nl>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4D7E89E7.3080505@xmsnet.nl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hans de Bruin <jmdebruin@xmsnet.nl>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

linux-mm cc'd

On Mon, Mar 14, 2011 at 10:34:31PM +0100, Hans de Bruin wrote:
> Since the start of the start of 2.6.38-rc I sporadic have problems
> with mplayer. A mpeg stream sometimes gets distorted when mplayer
> starts. An example is at http://www.xs4all.nl/~bruinjm/mplayer.png .
> I do not know how to trigger the behaviour, so bissecting is not
> possible. Since yesterday however I found a way to 'repair' mplayer:
> 
> echo 3 > /proc/sys/vm/drop_caches
> 
> This repairs mplayer while it is running.

While echo is running?  Or does one cache drop fix the problem until
mplayer exits?  Could you describe exactly the steps you are going
through and the effects they have?

Thanks!

> My latop is runs on nfsroot, and the mpegstreams are payed over nfs
> or http. I can have two instances of mplayer running the same mpeg
> stream over nfs or http with only one instance distorded.
> 
> -- 
> Hans
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
