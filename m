Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id B3D566B006C
	for <linux-mm@kvack.org>; Wed, 28 Nov 2012 16:39:09 -0500 (EST)
Message-ID: <50B68467.5020008@zytor.com>
Date: Wed, 28 Nov 2012 13:38:47 -0800
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 0/5] Add movablecore_map boot option
References: <1353667445-7593-1-git-send-email-tangchen@cn.fujitsu.com> <50B5CFAE.80103@huawei.com> <3908561D78D1C84285E8C5FCA982C28F1C95EDCE@ORSMSX108.amr.corp.intel.com>
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F1C95EDCE@ORSMSX108.amr.corp.intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Tang Chen <tangchen@cn.fujitsu.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "rob@landley.net" <rob@landley.net>, "isimatu.yasuaki@jp.fujitsu.com" <isimatu.yasuaki@jp.fujitsu.com>, "laijs@cn.fujitsu.com" <laijs@cn.fujitsu.com>, "wency@cn.fujitsu.com" <wency@cn.fujitsu.com>, "linfeng@cn.fujitsu.com" <linfeng@cn.fujitsu.com>, "yinghai@kernel.org" <yinghai@kernel.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, "mgorman@suse.de" <mgorman@suse.de>, "rientjes@google.com" <rientjes@google.com>, "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Len Brown <lenb@kernel.org>, "Wang, Frank" <frank.wang@intel.com>

On 11/28/2012 01:34 PM, Luck, Tony wrote:
>>
>> 2. use boot option
>>   This is our proposal. New boot option can specify memory range to use
>>   as movable memory.
> 
> Isn't this just moving the work to the user? To pick good values for the
> movable areas, they need to know how the memory lines up across
> node boundaries ... because they need to make sure to allow some
> non-movable memory allocations on each node so that the kernel can
> take advantage of node locality.
> 
> So the user would have to read at least the SRAT table, and perhaps
> more, to figure out what to provide as arguments.
> 
> Since this is going to be used on a dynamic system where nodes might
> be added an removed - the right values for these arguments might
> change from one boot to the next. So even if the user gets them right
> on day 1, a month later when a new node has been added, or a broken
> node removed the values would be stale.
> 

I gave this feedback in person at LCE: I consider the kernel
configuration option to be useless for anything other than debugging.
Trying to promote it as an actual solution, to be used by end users in
the field, is ridiculous at best.

	-hpa


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
