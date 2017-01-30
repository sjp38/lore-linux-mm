Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6BCE26B0274
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 11:15:15 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id i34so114037930qkh.6
        for <linux-mm@kvack.org>; Mon, 30 Jan 2017 08:15:15 -0800 (PST)
Received: from www62.your-server.de (www62.your-server.de. [213.133.104.62])
        by mx.google.com with ESMTPS id y128si9834778qkc.255.2017.01.30.08.15.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Jan 2017 08:15:14 -0800 (PST)
Message-ID: <588F668C.6090309@iogearbox.net>
Date: Mon, 30 Jan 2017 17:15:08 +0100
From: Daniel Borkmann <daniel@iogearbox.net>
MIME-Version: 1.0
Subject: Re: [PATCH 0/6 v3] kvmalloc
References: <20170126074354.GB8456@dhcp22.suse.cz> <5889C331.7020101@iogearbox.net> <20170126100802.GF6590@dhcp22.suse.cz> <5889DEA3.7040106@iogearbox.net> <20170126115833.GI6590@dhcp22.suse.cz> <5889F52E.7030602@iogearbox.net> <20170126134004.GM6590@dhcp22.suse.cz> <588A5D3C.4060605@iogearbox.net> <20170127100544.GF4143@dhcp22.suse.cz> <588BA9AA.8010805@iogearbox.net> <20170130075626.GC8443@dhcp22.suse.cz>
In-Reply-To: <20170130075626.GC8443@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, marcelo.leitner@gmail.com

On 01/30/2017 08:56 AM, Michal Hocko wrote:
> On Fri 27-01-17 21:12:26, Daniel Borkmann wrote:
>> On 01/27/2017 11:05 AM, Michal Hocko wrote:
>>> On Thu 26-01-17 21:34:04, Daniel Borkmann wrote:
> [...]
>>>> So to answer your second email with the bpf and netfilter hunks, why
>>>> not replacing them with kvmalloc() and __GFP_NORETRY flag and add that
>>>> big fat FIXME comment above there, saying explicitly that __GFP_NORETRY
>>>> is not harmful though has only /partial/ effect right now and that full
>>>> support needs to be implemented in future. That would still be better
>>>> that not having it, imo, and the FIXME would make expectations clear
>>>> to anyone reading that code.
>>>
>>> Well, we can do that, I just would like to prevent from this (ab)use
>>> if there is no _real_ and _sensible_ usecase for it. Having a real bug
>>
>> Understandable.
>>
>>> report or a fallback mechanism you are mentioning above would justify
>>> the (ab)use IMHO. But that abuse would be documented properly and have a
>>> real reason to exist. That sounds like a better approach to me.
>>>
>>> But if you absolutely _insist_ I can change that.
>>
>> Yeah, please do (with a big FIXME comment as mentioned), this originally
>> came from a real bug report. Anyway, feel free to add my Acked-by then.
>
> Thanks! I will repost the whole series today.

Looks like I got only Cc'ed on the cover letter of your v3 from today
(should have been v4 actually?). Anyway, I looked up the last patch
on lkml [1] and it seems you forgot the __GFP_NORETRY we talked about?
At least that was what was discussed above (insisting on __GFP_NORETRY
plus FIXME comment) for providing my Acked-by then. Can you still fix
that up in a final respin?

Thanks again,
Daniel

   [1] https://lkml.org/lkml/2017/1/30/129

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
