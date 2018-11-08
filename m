Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id C127C6B05AF
	for <linux-mm@kvack.org>; Thu,  8 Nov 2018 04:06:37 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id d17-v6so10946411edv.4
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 01:06:37 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v24-v6si568192edd.33.2018.11.08.01.06.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Nov 2018 01:06:36 -0800 (PST)
Subject: Re: stable request: mm, page_alloc: actually ignore mempolicies for
 high priority allocations
References: <a66fb268-74fe-6f4e-a99f-3257b8a5ac3b@vyatta.att-mail.com>
 <08ae2e51-672a-37de-2aa6-4e49dbc9de02@suse.cz>
 <fa553398-f4bf-3d57-376b-94593fb2c127@vyatta.att-mail.com>
 <20181108090154.GJ2453@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <4ad07955-05d5-80ea-ebf1-876b0dc6347a@suse.cz>
Date: Thu, 8 Nov 2018 10:06:35 +0100
MIME-Version: 1.0
In-Reply-To: <20181108090154.GJ2453@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Mike Manning <mmanning@vyatta.att-mail.com>
Cc: stable@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Mel Gorman <mgorman@techsingularity.net>, linux-mm <linux-mm@kvack.org>

On 11/8/18 10:01 AM, Michal Hocko wrote:
> On Thu 08-11-18 08:30:40, Mike Manning wrote:
> [...]
>> 1) The original commit was not suitable for backport to 4.14 and should
>> be reverted.
> 
> Yes, the original patch hasn't been marked for the stable tree and as
> such shouldn't have been backported. Even though it looks simple enough
> it is not really trivial.

I think you confused the two patches.

Original commit 1d26c112959f ("mm, page_alloc: do not break
__GFP_THISNODE by zonelist reset") was marked for stable, especially
pre-4.7 where SLAB could be potentially broken.

Commit d6a24df00638 ("mm, page_alloc: actually ignore mempolicies for
high priority allocations") was not marked stable and is being requested
in this thread. But I'm reluctant to agree with this without properly
understanding what went wrong.
