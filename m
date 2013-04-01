Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 64DEF6B0002
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 08:44:54 -0400 (EDT)
Message-ID: <51598168.4050404@parallels.com>
Date: Mon, 1 Apr 2013 16:45:28 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 00/28] memcg-aware slab shrinking
References: <1364548450-28254-1-git-send-email-glommer@parallels.com> <20130401123843.GC5217@sergelap>
In-Reply-To: <20130401123843.GC5217@sergelap>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Serge Hallyn <serge.hallyn@ubuntu.com>
Cc: linux-mm@kvack.org, hughd@google.com, containers@lists.linux-foundation.org, Dave Shrinnker <david@fromorbit.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

On 04/01/2013 04:38 PM, Serge Hallyn wrote:
> Quoting Glauber Costa (glommer@parallels.com):
>> Hi,
>>
>> Notes:
>> ======
>>
>> This is v2 of memcg-aware LRU shrinking. I've been testing it extensively
>> and it behaves well, at least from the isolation point of view. However,
>> I feel some more testing is needed before we commit to it. Still, this is
>> doing the job fairly well. Comments welcome.
> 
> Do you have any performance tests (preferably with enough runs with and
> without this patchset to show 95% confidence interval) to show the
> impact this has?  Certainly the feature sounds worthwhile, but I'm
> curious about the cost of maintaining this extra state.
> 
> -serge
> 
Not yet. I intend to include them in my next run. I haven't yet decided
on a set of tests to run (maybe just a memcg-contained kernel compile?)

So if you have suggestions of what I could run to show this, feel free
to lay them down here.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
