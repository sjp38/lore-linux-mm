Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f46.google.com (mail-ee0-f46.google.com [74.125.83.46])
	by kanga.kvack.org (Postfix) with ESMTP id 43D186B0031
	for <linux-mm@kvack.org>; Tue,  7 Jan 2014 17:13:18 -0500 (EST)
Received: by mail-ee0-f46.google.com with SMTP id d49so334780eek.33
        for <linux-mm@kvack.org>; Tue, 07 Jan 2014 14:13:17 -0800 (PST)
Received: from one.firstfloor.org (one.firstfloor.org. [193.170.194.197])
        by mx.google.com with ESMTPS id p9si90835233eew.76.2014.01.07.14.13.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 07 Jan 2014 14:13:17 -0800 (PST)
Date: Tue, 7 Jan 2014 23:13:16 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] Add a sysctl for numa_balancing v2
Message-ID: <20140107221316.GF20765@two.firstfloor.org>
References: <1389053326-29462-1-git-send-email-andi@firstfloor.org>
 <20140107135817.7f3befadebe843761d08b812@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140107135817.7f3befadebe843761d08b812@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andi Kleen <ak@linux.intel.com>, Mel Gorman <mel@csn.ul.ie>

On Tue, Jan 07, 2014 at 01:58:17PM -0800, Andrew Morton wrote:
> On Mon,  6 Jan 2014 16:08:46 -0800 Andi Kleen <andi@firstfloor.org> wrote:
> 
> > From: Andi Kleen <ak@linux.intel.com>
> > 
> > [It turns out the documentation patch was already merged
> > earlier. So just resending without documentation.]
> 
> Confused.  How could we have merged the documentation for this feature
> but not the feature itself?

Originally all numa balancing sysctl were undocumented. I had 
a TBD for this in my original patch. Mel then documented them,
but also included the documentation for the new sysctl in that patch.
Mel's documentation patch was then merged
(as part of his regular merges I suppose), but the global sysctl
patch wasn't.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
