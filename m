Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id C70FF6B0033
	for <linux-mm@kvack.org>; Mon, 15 Jul 2013 13:59:12 -0400 (EDT)
Received: by mail-vb0-f41.google.com with SMTP id p13so3350991vbe.14
        for <linux-mm@kvack.org>; Mon, 15 Jul 2013 10:59:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130711145625.GK21667@dhcp22.suse.cz>
References: <1373044710-27371-1-git-send-email-handai.szj@taobao.com>
 <1373045623-27712-1-git-send-email-handai.szj@taobao.com> <20130711145625.GK21667@dhcp22.suse.cz>
From: Greg Thelen <gthelen@google.com>
Date: Mon, 15 Jul 2013 10:58:51 -0700
Message-ID: <CAHH2K0avjz=H8k2zo-P-QJt=9f61GoAmq+ceECzGNxdUx1PWbA@mail.gmail.com>
Subject: Re: [PATCH V4 5/6] memcg: patch mem_cgroup_{begin,end}_update_page_stat()
 out if only root memcg exists
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Sha Zhengju <handai.szj@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cgroups@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Mel Gorman <mgorman@suse.de>, Sha Zhengju <handai.szj@taobao.com>

On Thu, Jul 11, 2013 at 7:56 AM, Michal Hocko <mhocko@suse.cz> wrote:
> On Sat 06-07-13 01:33:43, Sha Zhengju wrote:
>> From: Sha Zhengju <handai.szj@taobao.com>
>>
>> If memcg is enabled and no non-root memcg exists, all allocated
>> pages belongs to root_mem_cgroup and wil go through root memcg
>> statistics routines.  So in order to reduce overheads after adding
>> memcg dirty/writeback accounting in hot paths, we use jump label to
>> patch mem_cgroup_{begin,end}_update_page_stat() in or out when not
>> used.
>
> I do not think this is enough. How much do you save? One atomic read.
> This doesn't seem like a killer.

Given we're already using mem_cgroup_{begin,end}_update_page_stat(),
this optimization seems independent of memcg dirty/writeback
accounting.  Does this patch help memcg even before dirty/writeback
accounting?  If yes, then we have the option of splitting this
optimization out of the series.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
