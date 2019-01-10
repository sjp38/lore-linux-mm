Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id C8B518E0038
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 04:48:24 -0500 (EST)
Received: by mail-lj1-f199.google.com with SMTP id f5-v6so2561667ljj.17
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 01:48:24 -0800 (PST)
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id z16si56563772lfe.25.2019.01.10.01.48.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 01:48:23 -0800 (PST)
Subject: Re: [PATCH v2] netfilter: account ebt_table_info to kmemcg
References: <20190103031431.247970-1-shakeelb@google.com>
 <5cc8efad-9d3d-3136-3ddc-1f8a640cb1f8@virtuozzo.com>
 <2d8f28cb-8620-be05-21bc-dcf3009b2774@virtuozzo.com>
 <20190110094142.GI31793@dhcp22.suse.cz>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <4c8051dd-2214-49eb-a342-5ee2171665d1@virtuozzo.com>
Date: Thu, 10 Jan 2019 12:48:17 +0300
MIME-Version: 1.0
In-Reply-To: <20190110094142.GI31793@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Shakeel Butt <shakeelb@google.com>, Andrew Morton <akpm@linux-foundation.org>, Florian Westphal <fw@strlen.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, syzbot+7713f3aa67be76b1552c@syzkaller.appspotmail.com, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, Roopa Prabhu <roopa@cumulusnetworks.com>, Nikolay Aleksandrov <nikolay@cumulusnetworks.com>, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, bridge@lists.linux-foundation.org

On 10.01.2019 12:41, Michal Hocko wrote:
> On Thu 10-01-19 12:22:09, Kirill Tkhai wrote:
> [...]
>>>> diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
>>>> index 491828713e0b..5e55cef0cec3 100644
>>>> --- a/net/bridge/netfilter/ebtables.c
>>>> +++ b/net/bridge/netfilter/ebtables.c
>>>> @@ -1137,14 +1137,16 @@ static int do_replace(struct net *net, const void __user *user,
>>>>  	tmp.name[sizeof(tmp.name) - 1] = 0;
>>>>  
>>>>  	countersize = COUNTER_OFFSET(tmp.nentries) * nr_cpu_ids;
>>>> -	newinfo = vmalloc(sizeof(*newinfo) + countersize);
>>>> +	newinfo = __vmalloc(sizeof(*newinfo) + countersize, GFP_KERNEL_ACCOUNT,
>>>> +			    PAGE_KERNEL);
>>
>> Do we need GFP_HIGHMEM here?
> 
> No. vmalloc adds __GPF_HIGHMEM implicitly (see __vmalloc_area_node).

Then OK, thanks for the explanation.

Kirill
