Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 113466B004D
	for <linux-mm@kvack.org>; Wed, 28 Mar 2012 22:48:54 -0400 (EDT)
Message-ID: <4F73CD75.6010807@suse.com>
Date: Thu, 29 Mar 2012 08:18:21 +0530
From: Suresh Jayaraman <sjayaraman@suse.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/6] buffered write IO controller in balance_dirty_pages()
References: <20120328121308.568545879@intel.com> <20120328211017.GF3376@redhat.com>
In-Reply-To: <20120328211017.GF3376@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: Fengguang Wu <fengguang.wu@intel.com>, Linux Memory Management List <linux-mm@kvack.org>, Andrea Righi <andrea@betterlinux.com>, Jeff Moyer <jmoyer@redhat.com>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On 03/29/2012 02:40 AM, Vivek Goyal wrote:
> On Wed, Mar 28, 2012 at 08:13:08PM +0800, Fengguang Wu wrote:
>>
>> Here is one possible solution to "buffered write IO controller", based on Linux
>> v3.3
>>
>> git://git.kernel.org/pub/scm/linux/kernel/git/wfg/linux.git  buffered-write-io-controller
>>
>> Features:
>> - support blkio.weight
> 
> So this does proportional write bandwidth division on bdi for buffered
> writes?

yes.

> 
>> - support blkio.throttle.buffered_write_bps
> 
> This is absolute limit systemwide or per bdi?

system-wide and Fengguang thinks that per bdi should be implemented
trivially.

> [..]
>> The test results included in the last patch look pretty good in despite of the
>> simple implementation.
>>
>>  [PATCH 1/6] blk-cgroup: move blk-cgroup.h in include/linux/blk-cgroup.h
>>  [PATCH 2/6] blk-cgroup: account dirtied pages
>>  [PATCH 3/6] blk-cgroup: buffered write IO controller - bandwidth weight
>>  [PATCH 4/6] blk-cgroup: buffered write IO controller - bandwidth limit
>>  [PATCH 5/6] blk-cgroup: buffered write IO controller - bandwidth limit interface
>>  [PATCH 6/6] blk-cgroup: buffered write IO controller - debug trace
>>
> 
> Hi Fengguang,
> 
> Only patch 0 and patch 4 have shown up in my mail box. Same seems to be
> the case for lkml. I am wondering what happened to rest of the patches.

Same here. But, the rest of the patches showed up much later. In any
case you can access the fullset from here

http://git.kernel.org/?p=linux/kernel/git/wfg/linux.git;a=shortlog;h=refs/heads/buffered-write-io-controller


> Will understand the patches better once I have the full set.
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
