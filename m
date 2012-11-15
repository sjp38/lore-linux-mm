Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 8E8DD6B004D
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 18:18:36 -0500 (EST)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [Patch v5 0/7] acpi,memory-hotplug: implement framework for hot removing memory
Date: Fri, 16 Nov 2012 00:22:58 +0100
Message-ID: <1637174.XPDXHMEQY8@vostro.rjw.lan>
In-Reply-To: <alpine.DEB.2.00.1211151450040.27188@chino.kir.corp.google.com>
References: <1352962777-24407-1-git-send-email-wency@cn.fujitsu.com> <alpine.DEB.2.00.1211151450040.27188@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Wen Congyang <wency@cn.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org, Len Brown <len.brown@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Jiang Liu <jiang.liu@huawei.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mgorman@suse.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Toshi Kani <toshi.kani@hp.com>

On Thursday, November 15, 2012 02:51:52 PM David Rientjes wrote:
> On Thu, 15 Nov 2012, Wen Congyang wrote:
> 
> > Note:
> > 1. The following commit in pm tree can be dropped now(The other two patches
> >    are already dropped):
> >    54c4c7db6cb94d7d1217df6d7fca6847c61744ab
> > 2. This patchset requires the following patch(It is in pm tree now)
> >    https://lkml.org/lkml/2012/11/1/225
> > 
> 
> So this is based on the acpi-general branch of 
> git.kernel.org/pub/scm/linux/kernel/git/rafael/linux-pm.git correct?

It should be based on that, yes.

> And the branch's HEAD commit 54c4c7db6cb9 ("ACPI / memory-hotplug: call 
> acpi_bus_trim() to remove memory device") can be reverted before this 
> series is applied?

Why?

Rafael


-- 
I speak only for myself.
Rafael J. Wysocki, Intel Open Source Technology Center.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
