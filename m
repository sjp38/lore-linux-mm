Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id BD87E6B0071
	for <linux-mm@kvack.org>; Thu, 25 Oct 2012 05:24:27 -0400 (EDT)
Date: Thu, 25 Oct 2012 11:24:24 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH] add some drop_caches documentation and info messsge
Message-ID: <20121025092424.GA16601@liondog.tnic>
References: <20121023164546.747e90f6.akpm@linux-foundation.org>
 <20121024062938.GA6119@dhcp22.suse.cz>
 <20121024125439.c17a510e.akpm@linux-foundation.org>
 <50884F63.8030606@linux.vnet.ibm.com>
 <20121024134836.a28d223a.akpm@linux-foundation.org>
 <20121024210600.GA17037@liondog.tnic>
 <50885B2E.5050500@linux.vnet.ibm.com>
 <20121024224817.GB8828@liondog.tnic>
 <5088725B.2090700@linux.vnet.ibm.com>
 <CAHGf_=pfdgoeG5pPJb+UgjqfieU1yxt=46FGW1=th0RbgVKNRQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CAHGf_=pfdgoeG5pPJb+UgjqfieU1yxt=46FGW1=th0RbgVKNRQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>

On Wed, Oct 24, 2012 at 08:56:45PM -0400, KOSAKI Motohiro wrote:
> > That effectively means removing it from the kernel since distros ship
> > with those config options off.  We don't want to do that since there
> > _are_ valid, occasional uses like benchmarking that we want to be
> > consistent.
> 
> Agreed. we don't want to remove valid interface never.

Ok, duly noted.

But let's discuss this a bit further. So, for the benchmarking aspect,
you're either going to have to always require dmesg along with
benchmarking results or /proc/vmstat, depending on where the drop_caches
stats end up.

Is this how you envision it?

And then there are the VM bug cases, where you might not always get
full dmesg from a panicked system. In that case, you'd want the kernel
tainting thing too, so that it at least appears in the oops backtrace.

Although the tainting thing might not be enough - a user could
drop_caches at some point in time and the oops happening much later
could be unrelated but that can't be expressed in taint flags.

So you'd need some sort of a drop_caches counter, I'd guess. Or a last
drop_caches timestamp something.

Am I understanding the intent correctly?

Thanks.

-- 
Regards/Gruss,
    Boris.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
