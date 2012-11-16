Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 0B4B56B0074
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 19:58:26 -0500 (EST)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [Patch v5 0/7] acpi,memory-hotplug: implement framework for hot removing memory
Date: Fri, 16 Nov 2012 02:02:50 +0100
Message-ID: <1404902.mCy2TVRL7G@vostro.rjw.lan>
In-Reply-To: <1353026459.12509.36.camel@misato.fc.hp.com>
References: <1352962777-24407-1-git-send-email-wency@cn.fujitsu.com> <1816934.8XPDQmK5xC@vostro.rjw.lan> <1353026459.12509.36.camel@misato.fc.hp.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org, Len Brown <len.brown@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Lai Jiangshan <laijs@cn.fujitsu.com>, Jiang Liu <jiang.liu@huawei.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

On Thursday, November 15, 2012 05:40:59 PM Toshi Kani wrote:
> > > Well, I have tried _really_ hard to apply this patchset, but pretty much
> > > none of the patches except for [1/7] applied for me.  I have no idea what
> > > tree they are against, but I'm pretty sure it's not my tree.
> > > 
> > > I _have_ applied patches [1-4/7] and pushed them to linux-pm.git/linux-next.
> > > I needed to fix up almost all of them so that they applied, so please check
> > > if my fixups make sense (and let me know ASAP if that's not the case).
> > > 
> > > If they are OK, please rebase the rest of the series on top of
> > > linux-pm.git/linux-next and repost.  I'm not going to take any more
> > > patches that don't apply from you.
> > > 
> > > Moreover, I'm not going to take any more ACPI memory hotplug patches
> > > for v3.8 except for the [5-7/7] from this series (after they have been
> > > rebased and _if_ they apply), so please don't submit any until the v3.8
> > > merge window closes (of course, you're free to post RFCs, but I will
> > > ignore them).
> > 
> > And by the way, if someone gives a "Reviewed-by" to a patch that _obviously_
> > doesn't apply, I will ignore any "Reviewed-by" from that person going forward,
> > because that quite obviously means you haven't even compared the patch with the
> > existing code and thus your "review" is worthless.
> 
> I was able to apply all his patches on top of the Linus's tree...

Ah, that may be because of my mistake.  Sorry about that.

I'll try again and see if that works (sigh).

Thanks,
Rafael


-- 
I speak only for myself.
Rafael J. Wysocki, Intel Open Source Technology Center.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
