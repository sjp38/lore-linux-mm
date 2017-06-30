Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id BF9132802FE
	for <linux-mm@kvack.org>; Fri, 30 Jun 2017 05:40:17 -0400 (EDT)
Received: by mail-ua0-f200.google.com with SMTP id w19so40480952uac.0
        for <linux-mm@kvack.org>; Fri, 30 Jun 2017 02:40:17 -0700 (PDT)
Received: from mail-ua0-x243.google.com (mail-ua0-x243.google.com. [2607:f8b0:400c:c08::243])
        by mx.google.com with ESMTPS id h15si3431563vkd.231.2017.06.30.02.40.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Jun 2017 02:40:16 -0700 (PDT)
Received: by mail-ua0-x243.google.com with SMTP id j53so8314226uaa.2
        for <linux-mm@kvack.org>; Fri, 30 Jun 2017 02:40:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170630083926.GA22923@dhcp22.suse.cz>
References: <20170629073509.623-1-mhocko@kernel.org> <20170629073509.623-3-mhocko@kernel.org>
 <CADZGycaXs-TsVN2xy_rpFE_ML5_rs=iYN6ZQZsAfjTVHFyLyEQ@mail.gmail.com> <20170630083926.GA22923@dhcp22.suse.cz>
From: Wei Yang <richard.weiyang@gmail.com>
Date: Fri, 30 Jun 2017 17:39:56 +0800
Message-ID: <CADZGyca1-CzaHoR-==DN4kK_YrwmMVnKvowUv-5M4GQP7ZYubg@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm, memory_hotplug: remove zone restrictions
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Xishi Qiu <qiuxishi@huawei.com>, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jun 30, 2017 at 4:39 PM, Michal Hocko <mhocko@kernel.org> wrote:
> On Fri 30-06-17 11:09:51, Wei Yang wrote:
>> On Thu, Jun 29, 2017 at 3:35 PM, Michal Hocko <mhocko@kernel.org> wrote:
>> > From: Michal Hocko <mhocko@suse.com>
>> >
>>
>> Michal,
>>
>> I love the idea very much.
>>

>
> You haven't written your sequence of onlining but if you used the same
> one as mentioned in the patch then you should get
> memory34/valid_zones:Normal
> memory35/valid_zones:Normal Movable
> memory36/valid_zones:Normal Movable
> memory37/valid_zones:Normal Movable
> memory38/valid_zones:Normal Movable
> memory39/valid_zones:Normal
> memory40/valid_zones:Movable Normal
> memory41/valid_zones:Movable Normal
>
> Even if you kept 37 as movable and offline 38 you wouldn't get 38-41
> movable by default because...
>

Yes, it depends on the zone range.

>> The reason is the same, we don't adjust the zone's range when offline
>> memory.
>
> .. of this.
>
>> This is also a known issue?
>
> yes and to be honest I do not plan to fix it unless somebody has a real
> life usecase for it. Now that we allow explicit onlininig type anywhere
> it seems like a reasonable behavior and this will allow us to remove
> quite some code which is always a good deal wrt longterm maintenance.
>

hmm... the statistics displayed in /proc/zoneinfo would be meaningless
for zone_normal and zone_movable.

I am not sure, maybe no one care about these fields.

> Thanks!
> --
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
