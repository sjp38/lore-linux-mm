Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f173.google.com (mail-lb0-f173.google.com [209.85.217.173])
	by kanga.kvack.org (Postfix) with ESMTP id A78A36B0031
	for <linux-mm@kvack.org>; Wed, 27 Nov 2013 01:26:23 -0500 (EST)
Received: by mail-lb0-f173.google.com with SMTP id u14so5233151lbd.32
        for <linux-mm@kvack.org>; Tue, 26 Nov 2013 22:26:22 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id y7si18599875lal.104.2013.11.26.22.26.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 26 Nov 2013 22:26:22 -0800 (PST)
Message-ID: <52959089.6030607@parallels.com>
Date: Wed, 27 Nov 2013 10:26:17 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v11 00/15] kmemcg shrinkers
References: <cover.1385377616.git.vdavydov@parallels.com> <20131125174135.GE22729@cmpxchg.org> <529443E4.7080602@parallels.com> <20131126224742.GB10988@dastard>
In-Reply-To: <20131126224742.GB10988@dastard>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, akpm@linux-foundation.org, mhocko@suse.cz, glommer@openvz.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org

On 11/27/2013 02:47 AM, Dave Chinner wrote:
> On Tue, Nov 26, 2013 at 10:47:00AM +0400, Vladimir Davydov wrote:
>> Hi,
>>
>> Thank you for the review. I agree with all your comments and I'll
>> resend the fixed version soon.
>>
>> If anyone still has something to say about the patchset, I'd be glad
>> to hear from them.
> Please CC me on all the shrinker/list-lru changes being made as I am
> the original author of the list-lru code and the shrinker
> integration and have more than a passing interest in ensuring
> it doesn't get broken or crippled....

Sure, thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
