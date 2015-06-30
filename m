Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id E683A6B0032
	for <linux-mm@kvack.org>; Mon, 29 Jun 2015 22:01:29 -0400 (EDT)
Received: by pdbci14 with SMTP id ci14so126479766pdb.2
        for <linux-mm@kvack.org>; Mon, 29 Jun 2015 19:01:29 -0700 (PDT)
Received: from mgwym01.jp.fujitsu.com (mgwym01.jp.fujitsu.com. [211.128.242.40])
        by mx.google.com with ESMTPS id z1si67346118pda.165.2015.06.29.19.01.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jun 2015 19:01:29 -0700 (PDT)
Received: from m3051.s.css.fujitsu.com (m3051.s.css.fujitsu.com [10.134.21.209])
	by yt-mxoi2.gw.nic.fujitsu.com (Postfix) with ESMTP id 4DC79AC0219
	for <linux-mm@kvack.org>; Tue, 30 Jun 2015 11:01:25 +0900 (JST)
Message-ID: <5591F862.7030706@jp.fujitsu.com>
Date: Tue, 30 Jun 2015 11:01:06 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC v2 PATCH 7/8] mm: add the buddy system interface
References: <558E084A.60900@huawei.com> <558E0A28.6060607@huawei.com> <3908561D78D1C84285E8C5FCA982C28F32AA124A@ORSMSX114.amr.corp.intel.com> <5591EA50.1000000@jp.fujitsu.com> <5591F18E.3060504@huawei.com>
In-Reply-To: <5591F18E.3060504@huawei.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Hanjun Guo <guohanjun@huawei.com>, Xiexiuqi <xiexiuqi@huawei.com>, "leon@leon.nu" <leon@leon.nu>, "Hansen, Dave" <dave.hansen@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2015/06/30 10:31, Xishi Qiu wrote:
> On 2015/6/30 9:01, Kamezawa Hiroyuki wrote:
>
>> On 2015/06/30 8:11, Luck, Tony wrote:
>>>> @@ -814,7 +814,7 @@ int __init_memblock memblock_clear_hotplug(phys_addr_t base, phys_addr_t size)
>>>>     */
>>>>    int __init_memblock memblock_mark_mirror(phys_addr_t base, phys_addr_t size)
>>>>    {
>>>> -    system_has_some_mirror = true;
>>>> +    static_key_slow_inc(&system_has_mirror);
>>>>
>>>>        return memblock_setclr_flag(base, size, 1, MEMBLOCK_MIRROR);
>>>>    }
>>>
>>> This generates some WARN_ON noise when called from efi_find_mirror():
>>>
>>
>> It seems jump_label_init() is called after memory initialization. (init/main.c::start_kernel())
>> So, it may be difficut to use static_key function for our purpose because
>> kernel memory allocation may occur before jump_label is ready.
>>
>> Thanks,
>> -Kame
>>
>
> Hi Kame,
>
> How about like this? Use static bool in bootmem, and use jump label in buddy system.
> This means we use two variable to do it.
>

I think it can be done but it should be done in separated patch with enough comment/changelog.

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
