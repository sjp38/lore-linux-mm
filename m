Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id DC92D6B0044
	for <linux-mm@kvack.org>; Wed, 24 Oct 2012 17:06:02 -0400 (EDT)
Date: Wed, 24 Oct 2012 23:06:00 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH] add some drop_caches documentation and info messsge
Message-ID: <20121024210600.GA17037@liondog.tnic>
References: <20121012125708.GJ10110@dhcp22.suse.cz>
 <20121023164546.747e90f6.akpm@linux-foundation.org>
 <20121024062938.GA6119@dhcp22.suse.cz>
 <20121024125439.c17a510e.akpm@linux-foundation.org>
 <50884F63.8030606@linux.vnet.ibm.com>
 <20121024134836.a28d223a.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20121024134836.a28d223a.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>

On Wed, Oct 24, 2012 at 01:48:36PM -0700, Andrew Morton wrote:
> Well who knows. Could be that people's vm *does* suck. Or they have
> some particularly peculiar worklosd or requirement[*]. Or their VM
> *used* to suck, and the drop_caches is not really needed any more but
> it's there in vendor-provided code and they can't practically prevent
> it.

I have drop_caches in my suspend-to-disk script so that the hibernation
image is kept at minimum and suspend times are as small as possible.

Would that be a valid use-case?

-- 
Regards/Gruss,
    Boris.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
