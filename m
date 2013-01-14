Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 5F9F76B0071
	for <linux-mm@kvack.org>; Mon, 14 Jan 2013 12:33:50 -0500 (EST)
Message-ID: <50F440F5.3030006@zytor.com>
Date: Mon, 14 Jan 2013 09:31:33 -0800
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 0/5] Add movablecore_map boot option
References: <1358154925-21537-1-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1358154925-21537-1-git-send-email-tangchen@cn.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: akpm@linux-foundation.org, jiang.liu@huawei.com, wujianguo@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, linfeng@cn.fujitsu.com, yinghai@kernel.org, isimatu.yasuaki@jp.fujitsu.com, rob@landley.net, kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com, mgorman@suse.de, rientjes@google.com, guz.fnst@cn.fujitsu.com, rusty@rustcorp.com.au, lliubbo@gmail.com, jaegeuk.hanse@gmail.com, tony.luck@intel.com, glommer@parallels.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 01/14/2013 01:15 AM, Tang Chen wrote:
>
> For now, users can disable this functionality by not specifying the boot option.
> Later, we will post SRAT support, and add another option value "movablecore_map=acpi"
> to using SRAT.
>

I still think the option "movablecore_map" is uglier than hell.  "core" 
could just as easily refer to CPU cores there, but it is a memory mem. 
"movablemem" seems more appropriate.

Again, without SRAT I consider this patchset to be largely useless for 
anything other than prototyping work.

	-hpa

-- 
H. Peter Anvin, Intel Open Source Technology Center
I work for Intel.  I don't speak on their behalf.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
