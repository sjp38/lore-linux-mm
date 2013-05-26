Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 82A596B00BA
	for <linux-mm@kvack.org>; Sun, 26 May 2013 09:49:31 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id rl6so5972867pac.0
        for <linux-mm@kvack.org>; Sun, 26 May 2013 06:49:30 -0700 (PDT)
Message-ID: <51A212E1.40806@gmail.com>
Date: Sun, 26 May 2013 21:49:21 +0800
From: Hush Bensen <hush.bensen@gmail.com>
MIME-Version: 1.0
Subject: Re: [patch v2 3/6] mm/memory_hotplug: Disable memory hotremove for
 32bit
References: <1369547921-24264-1-git-send-email-liwanp@linux.vnet.ibm.com> <1369547921-24264-3-git-send-email-liwanp@linux.vnet.ibm.com> <20130526090054.GE10651@dhcp22.suse.cz> <CAHGf_=otK_LNgd6S09Fjjo0PfTSF3X0kj+=kGNyaTAze7m-b8w@mail.gmail.com> <51A203D4.6080001@gmail.com> <CAHGf_=pTEvunQ6fJQZ0MGwGmT31LryGmmfRUgC5T3AMzXQmx2w@mail.gmail.com>
In-Reply-To: <CAHGf_=pTEvunQ6fJQZ0MGwGmT31LryGmmfRUgC5T3AMzXQmx2w@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Michal Hocko <mhocko@suse.cz>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Jiang Liu <jiang.liu@huawei.com>, Tang Chen <tangchen@cn.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org

ao? 2013/5/26 21:06, KOSAKI Motohiro a??e??:
> On Sun, May 26, 2013 at 8:45 AM, Hush Bensen <hush.bensen@gmail.com> wrote:
>> ao? 2013/5/26 19:58, KOSAKI Motohiro a??e??:
>>
>>>>> As KOSAKI Motohiro mentioned, memory hotplug don't support 32bit since
>>>>> it was born,
>>>> Why? any reference? This reasoning is really weak.
>>> I have no seen any highmem support in memory hotplug code and I don't
>>> think this
>>> patch fixes all 32bit highmem issue. If anybody are interesting to
>>> support it, it is good thing. But in fact, _now_ it is broken when
>>> enable HIGHMEM.
>>
>> But online/offline memory can work well when enable HIGHMEM, isn't it?
> If you are lucky.
I think it can work well on my x86_32 with highmem enable box.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
