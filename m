Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 47D7A6B0003
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 17:38:00 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id f10so9414698qtc.0
        for <linux-mm@kvack.org>; Tue, 10 Apr 2018 14:38:00 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id c42si1881585qtc.107.2018.04.10.14.37.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Apr 2018 14:37:58 -0700 (PDT)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [RFC PATCH 1/1 v2] vmscan: Support multiple kswapd threads per
 node
From: Buddy Lumpkin <buddy.lumpkin@oracle.com>
In-Reply-To: <20180406073809.GF8286@dhcp22.suse.cz>
Date: Tue, 10 Apr 2018 14:37:27 -0700
Content-Transfer-Encoding: 7bit
Message-Id: <9FBD9A5F-8381-4810-A480-806632EBBDFC@oracle.com>
References: <1522878594-52281-1-git-send-email-buddy.lumpkin@oracle.com>
 <20180405061015.GU6312@dhcp22.suse.cz>
 <99DC1801-1ADC-488B-BA8D-736BCE4BA372@oracle.com>
 <20180406073809.GF8286@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, hannes@cmpxchg.org, riel@surriel.com, mgorman@suse.de, willy@infradead.org, akpm@linux-foundation.org


> On Apr 6, 2018, at 12:38 AM, Michal Hocko <mhocko@kernel.org> wrote:
> 
> On Thu 05-04-18 23:25:14, Buddy Lumpkin wrote:
>> 
>>> On Apr 4, 2018, at 11:10 PM, Michal Hocko <mhocko@kernel.org> wrote:
>>> 
>>> On Wed 04-04-18 21:49:54, Buddy Lumpkin wrote:
>>>> v2:
>>>> - Make update_kswapd_threads_node less racy
>>>> - Handle locking for case where CONFIG_MEMORY_HOTPLUG=n
>>> 
>>> Please do not repost with such a small changes. It is much more
>>> important to sort out the big picture first and only then deal with
>>> minor implementation details. The more versions you post the more
>>> fragmented and messy the discussion will become.
>>> 
>>> You will have to be patient because this is a rather big change and it
>>> will take _quite_ some time to get sorted.
>>> 
>>> Thanks!
>>> -- 
>>> Michal Hocko
>>> SUSE Labs
>>> 
>> 
>> 
>> Sorry about that, I actually had three people review my code internally,
>> then I managed to send out an old version. 100% guilty of submitting
>> code when I needed sleep. As for the change, that was in response
>> to a request from Andrew to make the update function less racy.
>> 
>> Should I resend a correct v2 now that the thread exists?
> 
> Let's just discuss open questions for now. Specifics of the code are the
> least interesting at this stage.
> 
> If you want some help with the code review, you can put it somewhere in
> the git tree and send a reference for those who are interested.
> -- 
> Michal Hocko
> SUSE Labs

Ok, I will go back through the thread and make sure all questions and
concerns have been addressed.
