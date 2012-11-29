Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 5BC966B0072
	for <linux-mm@kvack.org>; Thu, 29 Nov 2012 11:07:41 -0500 (EST)
Message-ID: <50B7882D.5060100@zytor.com>
Date: Thu, 29 Nov 2012 08:07:09 -0800
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 0/5] Add movablecore_map boot option
References: <1353667445-7593-1-git-send-email-tangchen@cn.fujitsu.com> <50B5CFAE.80103@huawei.com> <3908561D78D1C84285E8C5FCA982C28F1C95EDCE@ORSMSX108.amr.corp.intel.com> <50B68467.5020008@zytor.com> <20121129110045.GX8218@suse.de>
In-Reply-To: <20121129110045.GX8218@suse.de>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: "Luck, Tony" <tony.luck@intel.com>, Jiang Liu <jiang.liu@huawei.com>, Tang Chen <tangchen@cn.fujitsu.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "rob@landley.net" <rob@landley.net>, "isimatu.yasuaki@jp.fujitsu.com" <isimatu.yasuaki@jp.fujitsu.com>, "laijs@cn.fujitsu.com" <laijs@cn.fujitsu.com>, "wency@cn.fujitsu.com" <wency@cn.fujitsu.com>, "linfeng@cn.fujitsu.com" <linfeng@cn.fujitsu.com>, "yinghai@kernel.org" <yinghai@kernel.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, "rientjes@google.com" <rientjes@google.com>, "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Len Brown <lenb@kernel.org>, "Wang, Frank" <frank.wang@intel.com>

On 11/29/2012 03:00 AM, Mel Gorman wrote:
> 
> I've not been paying a whole pile of attention to this because it's not an
> area I'm active in but I agree that configuring ZONE_MOVABLE like
> this at boot-time is going to be problematic. As awkward as it is, it
> would probably work out better to only boot with one node by default and
> then hot-add the nodes at runtime using either an online sysfs file or
> an online-reserved file that hot-adds the memory to ZONE_MOVABLE. Still
> clumsy but better than specifying addresses on the command line.
> 
> That said, I also find using ZONE_MOVABLE to be a problem in itself that
> will cause problems down the road. Maybe this was discussed already but
> just in case I'll describe the problems I see.
> 

Yes, and it does mean that we definitely don't want everything that can
be in ZONE_MOVABLE to be there without administrator control.  I suspect
that a lot of users of such platforms actually will not use the feature,
and don't want to take the substantial penalty.

The other bit is that if you really really want high reliability, memory
mirroring is the way to go; it is the only way you will be able to
hotremove memory without having to have a pre-event to migrate the
memory away from the affected node before the memory is offlined.

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
