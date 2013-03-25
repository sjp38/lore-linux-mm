Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id AE1436B008A
	for <linux-mm@kvack.org>; Mon, 25 Mar 2013 12:19:45 -0400 (EDT)
Received: by mail-da0-f53.google.com with SMTP id n34so2151287dal.26
        for <linux-mm@kvack.org>; Mon, 25 Mar 2013 09:19:44 -0700 (PDT)
Message-ID: <51507916.6030402@gmail.com>
Date: Tue, 26 Mar 2013 00:19:34 +0800
From: Jiang Liu <liuj97@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH v2, part4 00/39] Simplify mem_init() implementations
 and kill num_physpages
References: <1364109934-7851-1-git-send-email-jiang.liu@huawei.com> <1364112719.1975.4.camel@dabdike.int.hansenpartnership.com>
In-Reply-To: <1364112719.1975.4.camel@dabdike.int.hansenpartnership.com>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi James,
	Thanks for reminder, my patch series have been screwed up.
I will send another version and build a git tree on github.
	Thanks!
	Gerry
On 03/24/2013 04:11 PM, James Bottomley wrote:
> On Sun, 2013-03-24 at 15:24 +0800, Jiang Liu wrote:
>> The original goal of this patchset is to fix the bug reported by
>> https://bugzilla.kernel.org/show_bug.cgi?id=53501
>> Now it has also been expanded to reduce common code used by memory
>> initializion.
>>
>> This is the last part, previous three patch sets could be accessed at:
>> http://marc.info/?l=linux-mm&m=136289696323825&w=2
>> http://marc.info/?l=linux-mm&m=136290291524901&w=2
>> http://marc.info/?l=linux-mm&m=136345342831592&w=2
>>
>> This patchset applies to
>> https://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git since-3.8
> 
> You're going to have to have a git tree for this if you want this series
> testing on other architectures.  Plus cc'ing linux-arch would be a good
> idea for that case.  The patch series seems to be screwed up in the
> numbering:  The parisc patches 26/39 and 27/39 are identical.
> 
> James
> 
> 
> 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
