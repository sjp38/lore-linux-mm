Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 9017A6B00D4
	for <linux-mm@kvack.org>; Sun, 26 May 2013 14:09:38 -0400 (EDT)
Received: by mail-we0-f172.google.com with SMTP id w62so3955415wes.17
        for <linux-mm@kvack.org>; Sun, 26 May 2013 11:09:36 -0700 (PDT)
Date: Sun, 26 May 2013 20:09:33 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch v2 3/6] mm/memory_hotplug: Disable memory hotremove for
 32bit
Message-ID: <20130526180933.GA20270@dhcp22.suse.cz>
References: <1369547921-24264-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1369547921-24264-3-git-send-email-liwanp@linux.vnet.ibm.com>
 <20130526090054.GE10651@dhcp22.suse.cz>
 <CAHGf_=otK_LNgd6S09Fjjo0PfTSF3X0kj+=kGNyaTAze7m-b8w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHGf_=otK_LNgd6S09Fjjo0PfTSF3X0kj+=kGNyaTAze7m-b8w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Wanpeng Li <liwanp@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Jiang Liu <jiang.liu@huawei.com>, Tang Chen <tangchen@cn.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org

On Sun 26-05-13 07:58:42, KOSAKI Motohiro wrote:
> >> As KOSAKI Motohiro mentioned, memory hotplug don't support 32bit since
> >> it was born,
> >
> > Why? any reference? This reasoning is really weak.
> 
> I have no seen any highmem support in memory hotplug code and I don't think this
> patch fixes all 32bit highmem issue. If anybody are interesting to
> support it, it is good thing. But in fact, _now_ it is broken when
> enable HIGHMEM.
> So, I just want to mark broken until someone want to support highmem
> and verify overall.
> 
> And, yes, this patch is no good. Kconfig doesn't describe why disable
> when highmem.
> So,
> 
> depends on 64BIT || !HIGHMEM || BROKEN
> 
> maybe clear documentation more.

I have no objection to disbale the feature for HIGHMEM configurations I
was merely complaining that the patch didn't describe _why_.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
