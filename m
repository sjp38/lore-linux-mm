Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 5A6576B005D
	for <linux-mm@kvack.org>; Thu,  6 Dec 2012 19:19:00 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id xa7so5088986pbc.14
        for <linux-mm@kvack.org>; Thu, 06 Dec 2012 16:18:59 -0800 (PST)
Message-ID: <50C135EA.2030308@gmail.com>
Date: Fri, 07 Dec 2012 08:18:50 +0800
From: Jiang Liu <liuj97@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 5/5] page_alloc: Bootmem limit with movablecore_map
References: <1353667445-7593-1-git-send-email-tangchen@cn.fujitsu.com> <1353667445-7593-6-git-send-email-tangchen@cn.fujitsu.com> <50B36354.7040501@gmail.com> <50B36B54.7050506@cn.fujitsu.com> <50B38F69.6020902@zytor.com> <50B4304F.4070302@cn.fujitsu.com> <50B45021.2000009@zytor.com> <50C0D5C6.1050305@gmail.com> <50C0D8B5.6000304@zytor.com>
In-Reply-To: <50C0D8B5.6000304@zytor.com>
Content-Type: multipart/mixed;
 boundary="------------060103020608020905070302"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Wen Congyang <wency@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, wujianguo <wujianguo106@gmail.com>, akpm@linux-foundation.org, rob@landley.net, isimatu.yasuaki@jp.fujitsu.com, laijs@cn.fujitsu.com, linfeng@cn.fujitsu.com, jiang.liu@huawei.com, yinghai@kernel.org, kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com, mgorman@suse.de, rientjes@google.com, rusty@rustcorp.com.au, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, wujianguo@huawei.com, qiuxishi@huawei.com

This is a multi-part message in MIME format.
--------------060103020608020905070302
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit

On 12/07/2012 01:41 AM, H. Peter Anvin wrote:
> On 12/06/2012 09:28 AM, Jiang Liu wrote:
>> Hi hpa and Tang,
>> 	How do you think about the attached patches, which reserves memory
>> for hotplug from memblock/bootmem allocator at early booting stages?
> 
> I don't see any attached patches?
> 
> 	-hpa
> 
Sorry, I was a little sleepy and missed the attachment.



--------------060103020608020905070302
Content-Type: text/x-patch;
 name="0001-memblock-introduce-interfaces-to-assoicate-tag-and-d.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0001-memblock-introduce-interfaces-to-assoicate-tag-and-d.pa";
 filename*1="tch"


--------------060103020608020905070302--
