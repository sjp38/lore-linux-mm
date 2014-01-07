Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f42.google.com (mail-ee0-f42.google.com [74.125.83.42])
	by kanga.kvack.org (Postfix) with ESMTP id 7E3786B0035
	for <linux-mm@kvack.org>; Tue,  7 Jan 2014 18:01:51 -0500 (EST)
Received: by mail-ee0-f42.google.com with SMTP id e53so352937eek.29
        for <linux-mm@kvack.org>; Tue, 07 Jan 2014 15:01:50 -0800 (PST)
Received: from gir.skynet.ie (gir.skynet.ie. [193.1.99.77])
        by mx.google.com with ESMTPS id 5si90977526eei.123.2014.01.07.15.01.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 07 Jan 2014 15:01:50 -0800 (PST)
Date: Tue, 7 Jan 2014 23:01:47 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] Add a sysctl for numa_balancing v2
Message-ID: <20140107230147.GD5990@csn.ul.ie>
References: <1389053326-29462-1-git-send-email-andi@firstfloor.org>
 <20140107135817.7f3befadebe843761d08b812@linux-foundation.org>
 <20140107221316.GF20765@two.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20140107221316.GF20765@two.firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andi Kleen <ak@linux.intel.com>

On Tue, Jan 07, 2014 at 11:13:16PM +0100, Andi Kleen wrote:
> On Tue, Jan 07, 2014 at 01:58:17PM -0800, Andrew Morton wrote:
> > On Mon,  6 Jan 2014 16:08:46 -0800 Andi Kleen <andi@firstfloor.org> wrote:
> > 
> > > From: Andi Kleen <ak@linux.intel.com>
> > > 
> > > [It turns out the documentation patch was already merged
> > > earlier. So just resending without documentation.]
> > 
> > Confused.  How could we have merged the documentation for this feature
> > but not the feature itself?
> 
> Originally all numa balancing sysctl were undocumented. I had 
> a TBD for this in my original patch. Mel then documented them,
> but also included the documentation for the new sysctl in that patch.
> Mel's documentation patch was then merged
> (as part of his regular merges I suppose), but the global sysctl
> patch wasn't.
> 

Yeah, it was an oversight on my part. I can't remember if I accidentally
dropped Andi's patch or thought it had been merged already. Sorry.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
