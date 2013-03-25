Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 7949C6B0098
	for <linux-mm@kvack.org>; Mon, 25 Mar 2013 13:07:27 -0400 (EDT)
Message-ID: <5150843B.1020804@synopsys.com>
Date: Mon, 25 Mar 2013 22:37:07 +0530
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH v2, part4 00/39] Simplify mem_init() implementations
 and kill num_physpages
References: <1364109934-7851-1-git-send-email-jiang.liu@huawei.com> <1364112719.1975.4.camel@dabdike.int.hansenpartnership.com> <51507916.6030402@gmail.com>
In-Reply-To: <51507916.6030402@gmail.com>
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <liuj97@gmail.com>
Cc: James Bottomley <James.Bottomley@HansenPartnership.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>

On 03/25/2013 09:49 PM, Jiang Liu wrote:
> Hi James,
> 	Thanks for reminder, my patch series have been screwed up.
> I will send another version and build a git tree on github.
> 	Thanks!
> 	Gerry

Please don't forget conversion of the newly added arc and metag arches !

Thx,
-Vineet

> On 03/24/2013 04:11 PM, James Bottomley wrote:
>> On Sun, 2013-03-24 at 15:24 +0800, Jiang Liu wrote:
>>> The original goal of this patchset is to fix the bug reported by
>>> https://bugzilla.kernel.org/show_bug.cgi?id=53501
>>> Now it has also been expanded to reduce common code used by memory
>>> initializion.
>>>
>>> This is the last part, previous three patch sets could be accessed at:
>>> http://marc.info/?l=linux-mm&m=136289696323825&w=2
>>> http://marc.info/?l=linux-mm&m=136290291524901&w=2
>>> http://marc.info/?l=linux-mm&m=136345342831592&w=2
>>>
>>> This patchset applies to
>>> https://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git since-3.8
>>
>> You're going to have to have a git tree for this if you want this series
>> testing on other architectures.  Plus cc'ing linux-arch would be a good
>> idea for that case.  The patch series seems to be screwed up in the
>> numbering:  The parisc patches 26/39 and 27/39 are identical.
>>
>> James
>>
>>
>>
>>
>>
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
