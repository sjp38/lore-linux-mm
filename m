Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 0AF2C6B0032
	for <linux-mm@kvack.org>; Wed,  4 Sep 2013 04:58:53 -0400 (EDT)
Received: by mail-wi0-f176.google.com with SMTP id cb5so3110756wib.3
        for <linux-mm@kvack.org>; Wed, 04 Sep 2013 01:58:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130903224731.GC1412@cmpxchg.org>
References: <20130826133658.GA357@larmbr-lcx> <20130903224731.GC1412@cmpxchg.org>
From: Zhan Jianyu <nasa4836@gmail.com>
Date: Wed, 4 Sep 2013 16:58:12 +0800
Message-ID: <CAHz2CGXRz4ComkEZZBKknn-7g5fAtGCrKuJ+nrGNKZHsudYbYg@mail.gmail.com>
Subject: Re: [PATCH RESEND] mm/vmscan : use vmcan_swappiness( ) basing on
 MEMCG config to elimiate unnecessary runtime cost
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, mhocko@suse.cz, Balbir Singh <bsingharora@gmail.com>, kamezawa.hiroyu@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, riel@redhat.com, linux-kernel@vger.kernel.org

On Wed, Sep 4, 2013 at 6:47 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> On Mon, Aug 26, 2013 at 09:36:58PM +0800, larmbr wrote:
>> Currently, we get the vm_swappiness via vmscan_swappiness(), which
>> calls global_reclaim() to check if this is a global reclaim.
>>
>> Besides, the current implementation of global_reclaim() always returns
>> true for the !CONFIG_MEGCG case, and judges the other case by checking
>> whether scan_control->target_mem_cgroup is null or not.
>>
>> Thus, we could just use two versions of vmscan_swappiness() based on
>> MEMCG Kconfig , to eliminate the unnecessary run-time cost for
>> the !CONFIG_MEMCG at all, and to squash all memcg-related checking
>> into the CONFIG_MEMCG version.
>
> The compiler can easily detect that global_reclaim() always returns
> true for !CONFIG_MEMCG during compile time and not even generate a
> branch for this.
>

Hi, Johannes Weiner,

Thanks for your comment ;)

Andrew has pointed this out and this patch is abandoned.


--

Regards,
Zhan Jianyu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
