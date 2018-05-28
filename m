Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 23E6D6B026D
	for <linux-mm@kvack.org>; Mon, 28 May 2018 11:54:16 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id c187-v6so7585291pfa.20
        for <linux-mm@kvack.org>; Mon, 28 May 2018 08:54:16 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n8-v6si30044145plp.468.2018.05.28.08.54.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 28 May 2018 08:54:15 -0700 (PDT)
Subject: Re: [PATCH] doc: document scope NOFS, NOIO APIs
References: <20180424183536.GF30619@thunk.org>
 <20180524114341.1101-1-mhocko@kernel.org>
 <6c9df175-df6c-2531-b90c-318e4fff72bb@infradead.org>
 <20180525075217.GF11881@dhcp22.suse.cz>
From: Nikolay Borisov <nborisov@suse.com>
Message-ID: <7c5d8afb-563f-43fd-50ef-d532550983c7@suse.com>
Date: Mon, 28 May 2018 10:21:00 +0300
MIME-Version: 1.0
In-Reply-To: <20180525075217.GF11881@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Randy Dunlap <rdunlap@infradead.org>
Cc: Jonathan Corbet <corbet@lwn.net>, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, "Darrick J. Wong" <darrick.wong@oracle.com>, David Sterba <dsterba@suse.cz>



On 25.05.2018 10:52, Michal Hocko wrote:
> On Thu 24-05-18 09:37:18, Randy Dunlap wrote:
>> On 05/24/2018 04:43 AM, Michal Hocko wrote:
> [...]
>>> +The traditional way to avoid this deadlock problem is to clear __GFP_FS
>>> +resp. __GFP_IO (note the later implies clearing the first as well) in
>>
>>                             latter
> 
> ?
> No I really meant that clearing __GFP_IO implies __GFP_FS clearing
Sorry to barge in like that, but Randy is right.

<NIT WARNING>


https://www.merriam-webster.com/dictionary/latter

" of, relating to, or being the second of two groups or things or the
last of several groups or things referred to

</NIT WARNING>


> 
