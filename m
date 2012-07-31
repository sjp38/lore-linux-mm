Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 61FAF6B004D
	for <linux-mm@kvack.org>; Tue, 31 Jul 2012 16:57:39 -0400 (EDT)
Message-ID: <501846BE.6000004@redhat.com>
Date: Tue, 31 Jul 2012 16:57:34 -0400
From: Larry Woodman <lwoodman@redhat.com>
Reply-To: lwoodman@redhat.com
MIME-Version: 1.0
Subject: Re: [PATCH -alternative] mm: hugetlbfs: Close race during teardown
 of hugetlbfs shared page tables V2 (resend)
References: <20120720141108.GH9222@suse.de> <20120720143635.GE12434@tiehlicka.suse.cz> <20120720145121.GJ9222@suse.de> <alpine.LSU.2.00.1207222033030.6810@eggly.anvils> <50118E7F.8000609@redhat.com> <50120FA8.20409@redhat.com> <20120727102356.GD612@suse.de> <5016DC5F.7030604@redhat.com> <20120731124650.GO612@suse.de> <50181AA1.0@redhat.com> <20120731200650.GB19524@tiehlicka.suse.cz>
In-Reply-To: <20120731200650.GB19524@tiehlicka.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Linux-MM <linux-mm@kvack.org>, David Gibson <david@gibson.dropbear.id.au>, Ken Chen <kenchen@google.com>, Cong Wang <xiyou.wangcong@gmail.com>, LKML <linux-kernel@vger.kernel.org>

On 07/31/2012 04:06 PM, Michal Hocko wrote:
> On Tue 31-07-12 13:49:21, Larry Woodman wrote:
>> On 07/31/2012 08:46 AM, Mel Gorman wrote:
>>> Fundamentally I think the problem is that we are not correctly detecting
>>> that page table sharing took place during huge_pte_alloc(). This patch is
>>> longer and makes an API change but if I'm right, it addresses the underlying
>>> problem. The first VM_MAYSHARE patch is still necessary but would you mind
>>> testing this on top please?
>> Hi Mel, yes this does work just fine.  It ran for hours without a panic so
>> I'll Ack this one if you send it to the list.
> Hi Larry, thanks for testing! I have a different patch which tries to
> address this very same issue. I am not saying it is better or that it
> should be merged instead of Mel's one but I would be really happy if you
> could give it a try. We can discuss (dis)advantages of both approaches
> later.
>
> Thanks!
Sure, it will take me a day since I keep loosing the hardware to 
proproduce the
problem with.  I'll report back tomorrow.

Larry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
