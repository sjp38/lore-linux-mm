Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 7FD7A6B002B
	for <linux-mm@kvack.org>; Wed, 26 Sep 2012 13:56:38 -0400 (EDT)
Message-ID: <50634105.8060302@parallels.com>
Date: Wed, 26 Sep 2012 21:53:09 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 04/13] kmem accounting basic infrastructure
References: <1347977050-29476-1-git-send-email-glommer@parallels.com> <1347977050-29476-5-git-send-email-glommer@parallels.com> <20120926140347.GD15801@dhcp22.suse.cz> <20120926163648.GO16296@google.com> <50633D24.6020002@parallels.com> <CAOS58YNj-L4ocwn-c27ho4WPW41MKOeJbnLZ8N8r4eUkoxC7GA@mail.gmail.com>
In-Reply-To: <CAOS58YNj-L4ocwn-c27ho4WPW41MKOeJbnLZ8N8r4eUkoxC7GA@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, devel@openvz.org, linux-mm@kvack.org, Suleiman Souhlal <suleiman@google.com>, Frederic Weisbecker <fweisbec@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>

On 09/26/2012 09:44 PM, Tejun Heo wrote:
> Hello, Glauber.
> 
> On Wed, Sep 26, 2012 at 10:36 AM, Glauber Costa <glommer@parallels.com> wrote:
>> This was discussed multiple times. Our interest is to preserve existing
>> deployed setup, that were tuned in a world where kmem didn't exist.
>> Because we also feed kmem to the user counter, this may very well
>> disrupt their setup.
> 
> So, that can be served by .kmem_accounted at root, no?
> 
>> User memory, unlike kernel memory, may very well be totally in control
>> of the userspace application, so it is not unreasonable to believe that
>> extra pages appearing in a new kernel version may break them.
>>
>> It is actually a much worse compatibility problem than flipping
>> hierarchy, in comparison
> 
> Again, what's wrong with one switch at the root?
> 

I understand your trauma about over flexibility, and you know I share of
it. But I don't think there is any need to cap it here. Given kmem
accounted is perfectly hierarchical, and there seem to be plenty of
people who only care about user memory, I see no reason to disallow a
mixed use case here.

I must say that for my particular use case, enabling it unconditionally
would just work, so it is not that what I have in mind.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
