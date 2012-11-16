Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id E6B506B0072
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 19:49:12 -0500 (EST)
Message-ID: <1353026459.12509.36.camel@misato.fc.hp.com>
Subject: Re: [Patch v5 0/7] acpi,memory-hotplug: implement framework for hot
 removing memory
From: Toshi Kani <toshi.kani@hp.com>
Date: Thu, 15 Nov 2012 17:40:59 -0700
In-Reply-To: <1816934.8XPDQmK5xC@vostro.rjw.lan>
References: <1352962777-24407-1-git-send-email-wency@cn.fujitsu.com>
	 <9217155.1eDFuhkN55@vostro.rjw.lan> <1816934.8XPDQmK5xC@vostro.rjw.lan>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org, Len Brown <len.brown@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Lai Jiangshan <laijs@cn.fujitsu.com>, Jiang Liu <jiang.liu@huawei.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

> > Well, I have tried _really_ hard to apply this patchset, but pretty much
> > none of the patches except for [1/7] applied for me.  I have no idea what
> > tree they are against, but I'm pretty sure it's not my tree.
> > 
> > I _have_ applied patches [1-4/7] and pushed them to linux-pm.git/linux-next.
> > I needed to fix up almost all of them so that they applied, so please check
> > if my fixups make sense (and let me know ASAP if that's not the case).
> > 
> > If they are OK, please rebase the rest of the series on top of
> > linux-pm.git/linux-next and repost.  I'm not going to take any more
> > patches that don't apply from you.
> > 
> > Moreover, I'm not going to take any more ACPI memory hotplug patches
> > for v3.8 except for the [5-7/7] from this series (after they have been
> > rebased and _if_ they apply), so please don't submit any until the v3.8
> > merge window closes (of course, you're free to post RFCs, but I will
> > ignore them).
> 
> And by the way, if someone gives a "Reviewed-by" to a patch that _obviously_
> doesn't apply, I will ignore any "Reviewed-by" from that person going forward,
> because that quite obviously means you haven't even compared the patch with the
> existing code and thus your "review" is worthless.

I was able to apply all his patches on top of the Linus's tree...

> If you just want to say you agree with the patch, use "Acked-by".

Got it.

Thanks,
-Toshi


> Thanks,
> Rafael
> 
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
