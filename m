Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 580C560021B
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 14:03:15 -0500 (EST)
Date: Fri, 4 Dec 2009 11:03:10 -0800
From: Chris Wright <chrisw@redhat.com>
Subject: Re: [PATCH 2/9] ksm: let shared pages be swappable
Message-ID: <20091204190310.GI19624@x200.localdomain>
References: <20091202125501.GD28697@random.random>
 <20091203134610.586E.A69D9226@jp.fujitsu.com>
 <20091204135938.5886.A69D9226@jp.fujitsu.com>
 <20091204141617.f4c491e7.kamezawa.hiroyu@jp.fujitsu.com>
 <20091204171640.GE19624@x200.localdomain>
 <20091204185303.GL28697@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091204185303.GL28697@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Chris Wright <chrisw@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <ieidus@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* Andrea Arcangeli (aarcange@redhat.com) wrote:
> On Fri, Dec 04, 2009 at 09:16:40AM -0800, Chris Wright wrote:
> > That's why I mentioned the page of zeroes as the prime example of
> > something with a high mapcount that shouldn't really ever be evicted.
> 
> Just a nitpick, "never" is too much, it should remain evictable if
> somebody halts all VM from monitor and starts a workloads that fills
> RAM and runs for a very prolonged time pushing all VM into swap. This
> is especially true if we stick to the below approach and it isn't
> just 1 page in high-sharing.

Yup, I completely agree, that's what I was trying to convey by
"shouldn't really ever" ;-)

thanks,
-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
