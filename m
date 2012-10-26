Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 4D2F16B0071
	for <linux-mm@kvack.org>; Fri, 26 Oct 2012 03:45:50 -0400 (EDT)
Date: Fri, 26 Oct 2012 10:45:47 +0300
From: Mika =?utf-8?Q?Bostr=C3=B6m?= <bostik@bostik.iki.fi>
Subject: Re: [PATCH] add some drop_caches documentation and info messsge
Message-ID: <20121026074547.GA25935@bostik.iki.fi>
Reply-To: Mika =?utf-8?Q?Bostr=C3=B6m?= <bostik@bostik.iki.fi>
References: <20121012125708.GJ10110@dhcp22.suse.cz>
 <20121023164546.747e90f6.akpm@linux-foundation.org>
 <20121024062938.GA6119@dhcp22.suse.cz>
 <20121024125439.c17a510e.akpm@linux-foundation.org>
 <50884F63.8030606@linux.vnet.ibm.com>
 <20121024134836.a28d223a.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20121024134836.a28d223a.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>

On Wed, Oct 24, 2012 at 01:48:36PM -0700, Andrew Morton wrote:
> Dave Hansen <dave@linux.vnet.ibm.com> wrote:
> > What kind of interface _is_ it in the first place?  Is it really a
> > production-level thing that we expect users to be poking at?  Or, is it
> > a rarely-used debugging and benchmarking knob which is fair game for us
> > to tweak like this?
> 
> It was a rarely-used mainly-developer-only thing which, apparently, real
> people found useful at some point in the past.  Perhaps we should never
> have offered it.

I've found it useful on occasion when generating large public keys.
When key generation hangs due to not-enough-entropy, dropping all
caches (followed by an intensive read) has allowed the system to
collect enough entropy to let the key generation finish.

Usefulness of the trick is probably going the way of the dodo, thanks to
SSD's becoming more common.

-- 
 Mika BostrA?m                       Individualisti, eksistentialisti,
 www.iki.fi/bostik                  rationalisti ja mulkvisti
 GPG: 0x2AED22CC; 6FC9 8375 31B7 3BA2 B5DC  484E F19F 8AD6 2AED 22CC

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
