Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 0B3836B002C
	for <linux-mm@kvack.org>; Wed,  8 Feb 2012 10:26:49 -0500 (EST)
Date: Wed, 8 Feb 2012 15:26:46 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 00/15] Swap-over-NBD without deadlocking V8
Message-ID: <20120208152645.GK5938@suse.de>
References: <1328568978-17553-1-git-send-email-mgorman@suse.de>
 <CAJd=RBAvvzK=TXwDaEjq2t+uEuP2PSi6zaUj7EW4UbL_AUsJAg@mail.gmail.com>
 <20120207132745.GH5938@suse.de>
 <CAJd=RBDYMKRVSKVp3dAhTCtu_wNDyayCObVA7q6G=fbkKpmZUw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CAJd=RBDYMKRVSKVp3dAhTCtu_wNDyayCObVA7q6G=fbkKpmZUw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On Wed, Feb 08, 2012 at 08:51:11PM +0800, Hillf Danton wrote:
> On Tue, Feb 7, 2012 at 9:27 PM, Mel Gorman <mgorman@suse.de> wrote:
> > On Tue, Feb 07, 2012 at 08:45:18PM +0800, Hillf Danton wrote:
> >> If it is feasible to bypass hang by tuning min_mem_kbytes,
> >
> > No. Increasing or descreasing min_free_kbytes changes the timing but it
> > will still hang.
> >
> >> things may
> >> become simpler if NICs are also tagged.
> >
> > That would mean making changes to every driver and they do not necessarily
> > know what higher level protocol like TCP they are transmitting. How is
> > that simpler? What is the benefit?
> >
> The benefit is to avoid allocating sock buffer in softirq by recycling,
> then the changes in VM core maybe less.
> 

The VM is responsible for swapping. It's reasonable that the core
VM has responsibility for it without trying to shove complexity into
drivers or elsewhere unnecessarily. I see some benefit in following on
by recycling some skbs and only allocating from softirq if no recycled
skbs are available.  That potentially improves performance but I do not
recycling as a replacement.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
