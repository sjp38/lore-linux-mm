Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 7DA456B0071
	for <linux-mm@kvack.org>; Wed, 24 Oct 2012 18:48:19 -0400 (EDT)
Date: Thu, 25 Oct 2012 00:48:17 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH] add some drop_caches documentation and info messsge
Message-ID: <20121024224817.GB8828@liondog.tnic>
References: <20121012125708.GJ10110@dhcp22.suse.cz>
 <20121023164546.747e90f6.akpm@linux-foundation.org>
 <20121024062938.GA6119@dhcp22.suse.cz>
 <20121024125439.c17a510e.akpm@linux-foundation.org>
 <50884F63.8030606@linux.vnet.ibm.com>
 <20121024134836.a28d223a.akpm@linux-foundation.org>
 <20121024210600.GA17037@liondog.tnic>
 <50885B2E.5050500@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <50885B2E.5050500@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>

On Wed, Oct 24, 2012 at 02:18:38PM -0700, Dave Hansen wrote:
> Sounds fairly valid to me. But, it's also one that would not be harmed
> or disrupted in any way because of a single additional printk() during
> each suspend-to-disk operation.

Btw,

back to the drop_caches patch. How about we hide the drop_caches
interface behind some mm debugging option in "Kernel Hacking"? Assuming
we don't need it otherwise on production kernels. Probably make it
depend on CONFIG_DEBUG_VM like CONFIG_DEBUG_VM_RB or so.

And then also add it to /proc/vmstat, in addition.

-- 
Regards/Gruss,
    Boris.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
