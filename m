Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0886F6B05BF
	for <linux-mm@kvack.org>; Thu,  8 Nov 2018 04:41:50 -0500 (EST)
Received: by mail-yb1-f200.google.com with SMTP id w13-v6so12850133ybm.11
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 01:41:50 -0800 (PST)
Received: from mx0a-00191d01.pphosted.com (mx0a-00191d01.pphosted.com. [67.231.149.140])
        by mx.google.com with ESMTPS id e83-v6si2047489ywb.274.2018.11.08.01.41.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Nov 2018 01:41:49 -0800 (PST)
Reply-To: mmanning@vyatta.att-mail.com
Subject: Re: stable request: mm, page_alloc: actually ignore mempolicies for
 high priority allocations
References: <a66fb268-74fe-6f4e-a99f-3257b8a5ac3b@vyatta.att-mail.com>
 <08ae2e51-672a-37de-2aa6-4e49dbc9de02@suse.cz>
 <fa553398-f4bf-3d57-376b-94593fb2c127@vyatta.att-mail.com>
 <20181108090154.GJ2453@dhcp22.suse.cz>
 <4ad07955-05d5-80ea-ebf1-876b0dc6347a@suse.cz>
From: Mike Manning <mmanning@vyatta.att-mail.com>
Message-ID: <7300a8a8-588a-2182-f11f-280cbce36fca@vyatta.att-mail.com>
Date: Thu, 8 Nov 2018 09:41:37 +0000
MIME-Version: 1.0
In-Reply-To: <4ad07955-05d5-80ea-ebf1-876b0dc6347a@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>
Cc: stable@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Mel Gorman <mgorman@techsingularity.net>, linux-mm <linux-mm@kvack.org>

On 08/11/2018 09:06, Vlastimil Babka wrote:
> On 11/8/18 10:01 AM, Michal Hocko wrote:
>> On Thu 08-11-18 08:30:40, Mike Manning wrote:
>> [...]
>>> 1) The original commit was not suitable for backport to 4.14 and should
>>> be reverted.
>> Yes, the original patch hasn't been marked for the stable tree and as
>> such shouldn't have been backported. Even though it looks simple enough
>> it is not really trivial.
> I think you confused the two patches.
>
> Original commit 1d26c112959f ("mm, page_alloc: do not break
> __GFP_THISNODE by zonelist reset") was marked for stable, especially
> pre-4.7 where SLAB could be potentially broken.
>
> Commit d6a24df00638 ("mm, page_alloc: actually ignore mempolicies for
> high priority allocations") was not marked stable and is being requested
> in this thread. But I'm reluctant to agree with this without properly
> understanding what went wrong.

Apologies, the original commit was not a backport, but is a fix in 4.14
for pre-4.7 kernels.

All I can do from a user perspective is report the problem and the
fortuitous follow-on commit that resolved the issue in our case. It has
already taken quite some time to find that the problem was unexpectedly
due to the kernel upgrade (this failure is a first, we have been running
these tests for some years going back to the 4.1 kernel), then to go
through the process of pinpointing the change that caused the issue in
our case.

Given that the problem is not manually reproducible, and given that it
could take a very substantial period of time to understand how the
change is impacting our scale & performance testing, it seems most
expedient to backport the 1-line commit that resolves the issue.
