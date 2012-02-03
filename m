Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 519846B002C
	for <linux-mm@kvack.org>; Fri,  3 Feb 2012 11:06:52 -0500 (EST)
Date: Fri, 3 Feb 2012 17:06:37 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] Handling of unused variable 'do-numainfo on compilation
 time
Message-ID: <20120203160637.GB1690@cmpxchg.org>
References: <1328258627-2241-1-git-send-email-geunsik.lim@gmail.com>
 <20120203133950.GA1690@cmpxchg.org>
 <20120203145304.GA18335@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120203145304.GA18335@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Geunsik Lim <geunsik.lim@gmail.com>, linux-mm <linux-mm@kvack.org>

On Fri, Feb 03, 2012 at 03:53:04PM +0100, Michal Hocko wrote:
> On Fri 03-02-12 14:39:50, Johannes Weiner wrote:
> > Michal, this keeps coming up, please decide between the proposed
> > solutions ;-)
> 
> Hmm, I thought we already sorted this out https://lkml.org/lkml/2012/1/26/25 ?

Hah.  Sorry, I missed that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
