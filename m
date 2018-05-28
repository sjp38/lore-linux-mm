Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 605B26B0006
	for <linux-mm@kvack.org>; Mon, 28 May 2018 12:03:49 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id r4-v6so3127647pgq.2
        for <linux-mm@kvack.org>; Mon, 28 May 2018 09:03:49 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b9-v6si29606839pli.427.2018.05.28.09.03.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 28 May 2018 09:03:48 -0700 (PDT)
Subject: Re: [PATCH] doc: document scope NOFS, NOIO APIs
References: <20180424183536.GF30619@thunk.org>
 <20180524114341.1101-1-mhocko@kernel.org>
 <6c9df175-df6c-2531-b90c-318e4fff72bb@infradead.org>
 <20180525075217.GF11881@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <1f870f27-2ef9-fced-30d9-20cae52789b2@suse.cz>
Date: Mon, 28 May 2018 13:32:33 +0200
MIME-Version: 1.0
In-Reply-To: <20180525075217.GF11881@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Randy Dunlap <rdunlap@infradead.org>
Cc: Jonathan Corbet <corbet@lwn.net>, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, "Darrick J. Wong" <darrick.wong@oracle.com>, David Sterba <dsterba@suse.cz>

On 05/25/2018 09:52 AM, Michal Hocko wrote:
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

In that case "latter" is the proper word AFAIK. You could also use
"former" instead of "first". Or maybe just repeat the flag names to
avoid confusion...
