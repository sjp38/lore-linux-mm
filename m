Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9D48B6B005D
	for <linux-mm@kvack.org>; Tue, 11 Aug 2009 11:20:57 -0400 (EDT)
Subject: Re: Help Resource Counters Scale better (v4)
From: Andi Kleen <andi@firstfloor.org>
References: <20090811144405.GW7176@balbir.in.ibm.com>
	<4A81863A.2050504@redhat.com>
Date: Tue, 11 Aug 2009 17:20:54 +0200
In-Reply-To: <4A81863A.2050504@redhat.com> (Prarit Bhargava's message of "Tue, 11 Aug 2009 10:54:50 -0400")
Message-ID: <87d472gyw9.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Prarit Bhargava <prarit@redhat.com>
Cc: balbir@linux.vnet.ibm.com, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "menage@google.com" <menage@google.com>, andi.kleen@intel.com, Pavel Emelianov <xemul@openvz.org>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Prarit Bhargava <prarit@redhat.com> writes:
>
> On a 64p/32G system running 2.6.31-git2-rc5, with RESOURCE_COUNTERS

This is CONFIG_RESOURCE_COUNTERS off at compile time right?

> off, "time make -j64" results in
>
> real    4m54.972s
> user    90m13.456s
> sys     50m19.711s
>
> On the same system, running 2.6.31-git2-rc5, with RESOURCE_COUNTERS on,
> plus Balbir's "Help Resource Counters Scale Better (v3)" patch, and
> this patch, results in
>
> real    4m18.607s
> user    84m58.943s
> sys     50m52.682s

Hmm, so resource counters on with the patch is faster than
CONFIG_RESOURCE_COUNTERS compiled out in real time? That seems
counterintuitive. At best I would expect the patch to break even, but
not be actually faster.

Is the compilation stable over multiple runs?

Still it looks like the patch is clearly needed.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
