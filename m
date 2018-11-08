Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id DAD256B05A7
	for <linux-mm@kvack.org>; Thu,  8 Nov 2018 03:30:57 -0500 (EST)
Received: by mail-lf1-f71.google.com with SMTP id y12-v6so2452584lfh.16
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 00:30:57 -0800 (PST)
Received: from mx0a-00191d01.pphosted.com (mx0b-00191d01.pphosted.com. [67.231.157.136])
        by mx.google.com with ESMTPS id 10-v6si3149816ljp.205.2018.11.08.00.30.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Nov 2018 00:30:55 -0800 (PST)
Reply-To: mmanning@vyatta.att-mail.com
Subject: Re: stable request: mm, page_alloc: actually ignore mempolicies for
 high priority allocations
References: <a66fb268-74fe-6f4e-a99f-3257b8a5ac3b@vyatta.att-mail.com>
 <08ae2e51-672a-37de-2aa6-4e49dbc9de02@suse.cz>
From: Mike Manning <mmanning@vyatta.att-mail.com>
Message-ID: <fa553398-f4bf-3d57-376b-94593fb2c127@vyatta.att-mail.com>
Date: Thu, 8 Nov 2018 08:30:40 +0000
MIME-Version: 1.0
In-Reply-To: <08ae2e51-672a-37de-2aa6-4e49dbc9de02@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, stable@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Mel Gorman <mgorman@techsingularity.net>, linux-mm <linux-mm@kvack.org>

On 08/11/2018 07:54, Vlastimil Babka wrote:
> +CC linux-mm
>
> On 11/7/18 6:33 PM, Mike Manning wrote:
>> Hello, Please consider backporting to 4.14.y the following commit from
>> kernel-net-next by Vlastimil Babka [CC'ed]:
>>
>> d6a24df00638 ("mm, page_alloc: actually ignore mempolicies for high
>> priority allocations") It cherry-picks cleanly and builds fine.
>>
>> The reason for the request is that the commit 1d26c112959f ("mm,
>> page_alloc:do not break __GFP_THISNODE by zonelist reset") that was
>> previously backported to 4.14.y broke some of our functionality after we
>> upgraded from an earlier 4.14 kernel without the fix.
> Well, that's very surprising! Could you be more specific about what
> exactly got broken?

Thank you for your reply. I agree, we were also very surprised when
bisecting our updated 4.14 kernel, as this change is apparently
completely unrelated to our application running in userspace. But the
problem was 100% reproducible on a baremetal setup running automated
performance multi-stream testing, so only seen under load. With the fix
reverted from the 4.14 kernel, the problem went away, and this is with
many repeated runs (the load test is part of a suite that is
automatically run quite a few times every day, and this test was failing
since the upgrade).

>
>> The reason this is
>> happening is not clear, with this commit only found by bisect.
>> Fortunately the requested commit resolves the issue.
> I would like to understand the problem first, because I currently can't
> imagine how the first commit could break something and the second fix it.

I agree, but from an empirical point of view, 2 options present:

1) The original commit was not suitable for backport to 4.14 and should
be reverted.

2) For the same reason that the original commit was suitable for
backport to 4.14, the requested commit should also be backported.

>> Best Regards,
>>
>> Mike Manning
>>
