Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id B44256B0005
	for <linux-mm@kvack.org>; Sun, 14 Aug 2016 21:50:48 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id o124so94616773pfg.1
        for <linux-mm@kvack.org>; Sun, 14 Aug 2016 18:50:48 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id f84si23802410pfj.40.2016.08.14.18.50.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 14 Aug 2016 18:50:47 -0700 (PDT)
Message-ID: <57B11DAB.6080904@huawei.com>
Date: Mon, 15 Aug 2016 09:40:59 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] mem-hotplug: introduce movablenode option
References: <57A325CA.9050707@huawei.com> <20160811161335.8599521d14927394f1208fc7@linux-foundation.org>
In-Reply-To: <20160811161335.8599521d14927394f1208fc7@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H.
 Peter Anvin" <hpa@zytor.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, "'Kirill A . Shutemov'" <kirill.shutemov@linux.intel.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2016/8/12 7:13, Andrew Morton wrote:

> On Thu, 4 Aug 2016 19:23:54 +0800 Xishi Qiu <qiuxishi@huawei.com> wrote:
> 
>> This patch introduces a new boot option movablenode.
>>
>> To support memory hotplug, boot option "movable_node" is needed. And to
>> support debug memory hotplug, boot option "movable_node" and "movablenode"
>> are both needed.
>>
>> e.g. movable_node movablenode=1,2,4
> 
> I have some naming concerns.  "movable_node" and "movablenode" is just
> confusing and ugly.
> 

Hi Andrew,

OK, how about other two fix patches?

Thanks,
Xishi Qiu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
