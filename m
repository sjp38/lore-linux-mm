Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0A9586B000D
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 10:25:18 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id n194-v6so2792896itn.0
        for <linux-mm@kvack.org>; Tue, 31 Jul 2018 07:25:18 -0700 (PDT)
Received: from us.icdsoft.com (us.icdsoft.com. [192.252.146.184])
        by mx.google.com with ESMTPS id p65-v6si10457414iop.187.2018.07.31.07.25.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Jul 2018 07:25:15 -0700 (PDT)
Subject: Re: [Bug 200651] New: cgroups iptables-restor: vmalloc: allocation
 failure
References: <ed7090ad-5004-3133-3faf-607d2a9fa90a@suse.cz>
 <d69d7a82-5b70-051f-a517-f602c3ef1fd7@suse.cz>
 <98788618-94dc-5837-d627-8bbfa1ddea57@icdsoft.com>
 <ff19099f-e0f5-d2b2-e124-cc12d2e05dc1@icdsoft.com>
 <20180730135744.GT24267@dhcp22.suse.cz>
 <89ea4f56-6253-4f51-0fb7-33d7d4b60cfa@icdsoft.com>
 <20180730183820.GA24267@dhcp22.suse.cz>
 <56597af4-73c6-b549-c5d5-b3a2e6441b8e@icdsoft.com>
 <6838c342-2d07-3047-e723-2b641bc6bf79@suse.cz>
 <8105b7b3-20d3-5931-9f3c-2858021a4e12@icdsoft.com>
 <20180731140520.kpotpihqsmiwhh7l@breakpoint.cc>
From: Georgi Nikolov <gnikolov@icdsoft.com>
Message-ID: <9cee281e-e6f4-20d1-401c-3c8b6fb744db@icdsoft.com>
Date: Tue, 31 Jul 2018 17:25:04 +0300
MIME-Version: 1.0
In-Reply-To: <20180731140520.kpotpihqsmiwhh7l@breakpoint.cc>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Westphal <fw@strlen.de>
Cc: Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, netfilter-devel@vger.kernel.org

On 07/31/2018 05:05 PM, Florian Westphal wrote:
> Georgi Nikolov <gnikolov@icdsoft.com> wrote:
>>> No, I think that's rather for the netfilter folks to decide. However,=
 it
>>> seems there has been the debate already [1] and it was not found. The=

>>> conclusion was that __GFP_NORETRY worked fine before, so it should wo=
rk
>>> again after it's added back. But now we know that it doesn't...
>>>
>>> [1] https://lore.kernel.org/lkml/20180130140104.GE21609@dhcp22.suse.c=
z/T/#u
>> Yes i see. I will add Florian Westphal to CC list. netfilter-devel is
>> already in this list so probably have to wait for their opinion.
> It hasn't changed, I think having OOM killer zap random processes
> just because userspace wants to import large iptables ruleset is not a
> good idea.
And what about passing GFP_NORETRY only above some reasonable threshold?
Or situation has to be handled in userspace.


Regards,

--
Georgi Nikolov
