Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 59BE16B004A
	for <linux-mm@kvack.org>; Fri, 24 Feb 2012 14:27:03 -0500 (EST)
Message-ID: <4F47E47B.3000409@fb.com>
Date: Fri, 24 Feb 2012 11:26:51 -0800
From: Arun Sharma <asharma@fb.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: Enable MAP_UNINITIALIZED for archs with mmu
References: <1326912662-18805-1-git-send-email-asharma@fb.com> <CAKTCnzn-reG4bLmyWNYPELYs-9M3ZShEYeOix_OcnPow-w8PNg@mail.gmail.com> <4F468888.9090702@fb.com> <20120224114748.720ee79a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120224114748.720ee79a.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Balbir Singh <bsingharora@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org

On 2/23/12 6:47 PM, KAMEZAWA Hiroyuki wrote:
>>
>> In a distributed computing environment, a user submits a job to the
>> cluster job scheduler. The job might involve multiple related
>> executables and might involve multiple address spaces. But they're
>> performing one logical task, have a single resource limit enforced by a
>> cgroup.
>>
>> They don't have access to each other's VMAs, but if "accidentally" one
>> of them comes across an uninitialized page with data from another task,
>> it's not a violation of the security model.
>>
> How do you handle shared resouce, file-cache ?
>

 From a security perspective or a resource limit perspective?

Security: all processes in the cgroup run with the same uid and have the 
same access to the filesystem. Multiple address spaces in a cgroup can 
be thought of as an implementation detail.

Resource limit: We don't have strict enforcement right now. There is a 
desire to include everything (file cache, slab memory) in the job's 
memory resource limit.

  -Arun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
