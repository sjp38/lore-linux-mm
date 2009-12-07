Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 9A0686B0044
	for <linux-mm@kvack.org>; Sun,  6 Dec 2009 21:02:02 -0500 (EST)
Date: Sun, 6 Dec 2009 19:01:57 -0700
From: Alex Chiang <achiang@hp.com>
Subject: Re: [RFC] print symbolic page flag names in bad_page()
Message-ID: <20091207020157.GA394@ldl.fc.hp.com>
References: <20091204212606.29258.98531.stgit@bob.kio> <20091206034636.GA7109@localhost> <20091206230016.GA18989@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091206230016.GA18989@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Wu Fengguang <fengguang.wu@intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "Li, Haicheng" <haicheng.li@intel.com>, Randy Dunlap <randy.dunlap@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Christoph Lameter <cl@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

* Andi Kleen <andi@firstfloor.org>:
> > So how about this patch?
> 
> I like it. Decoding the flags by hand is always a very unpleasant experience.
> Bonus: dump_page can be called from kgdb too.

This is fine by me too.

Thanks,
/ac

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
