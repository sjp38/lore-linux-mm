Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 7A5F46B005A
	for <linux-mm@kvack.org>; Mon, 24 Sep 2012 11:40:13 -0400 (EDT)
Message-ID: <50607E0C.7020606@parallels.com>
Date: Mon, 24 Sep 2012 19:36:44 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 05/16] consider a memcg parameter in kmem_create_cache
References: <1347977530-29755-1-git-send-email-glommer@parallels.com> <1347977530-29755-6-git-send-email-glommer@parallels.com> <20120921181458.GG7264@google.com> <506015E7.8030900@parallels.com> <00000139f84bdedc-aae672a6-2908-4cb8-8ed3-8fedf67a21af-000000@email.amazonses.com> <50605500.5050606@parallels.com> <00000139f8836571-6ddc9d5b-1d5f-4542-92f9-ad11070e5b7d-000000@email.amazonses.com> <506063B8.70305@parallels.com> <00000139f890a302-980aee84-40b2-433f-8dbd-e7b1d219f00d-000000@email.amazonses.com> <506066E3.6050705@parallels.com> <CAOJsxLGFWQFNUUN3sDeB2sn0S-QM-6Ut_d02HjmF6mB5aMytoA@mail.gmail.com>
In-Reply-To: <CAOJsxLGFWQFNUUN3sDeB2sn0S-QM-6Ut_d02HjmF6mB5aMytoA@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Tejun Heo <tj@kernel.org>, "<linux-kernel@vger.kernel.org>" <linux-kernel@vger.kernel.org>, "<cgroups@vger.kernel.org>" <cgroups@vger.kernel.org>, "<kamezawa.hiroyu@jp.fujitsu.com>" <kamezawa.hiroyu@jp.fujitsu.com>, "<devel@openvz.org>" <devel@openvz.org>, "<linux-mm@kvack.org>" <linux-mm@kvack.org>, Suleiman Souhlal <suleiman@google.com>, Frederic Weisbecker <fweisbec@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>

On 09/24/2012 07:38 PM, Pekka Enberg wrote:
> On 09/24/2012 05:56 PM, Christoph Lameter wrote:
>>> On Mon, 24 Sep 2012, Glauber Costa wrote:
>>>
>>>> The reason I say it is orthogonal, is that people will still want to see
>>>> their caches in /proc/slabinfo, regardless of wherever else they'll be.
>>>> It was a requirement from Pekka in one of the first times I posted this,
>>>> IIRC.
>>>
>>> They want to see total counts there true. But as I said we already have a
>>> duplication of the statistics otherwise. We have never done the scheme
>>> that you propose. That is unexpected. I would not expect the numbers to be
>>> there.
> 
> On Mon, Sep 24, 2012 at 4:57 PM, Glauber Costa <glommer@parallels.com> wrote:
>> I myself personally believe it can potentially clutter slabinfo, and
>> won't put my energy in defending the current implementation. What I
>> don't want is to keep switching between implementations.
>>
>> Pekka, Tejun, what do you guys say here?
> 
> So Christoph is proposing that the new caches appear somewhere under
> the cgroups directory and /proc/slabinfo includes aggregated counts,
> right? I'm certainly OK with that.
> 
Just for clarification, I am not sure about the aggregate counts -
although it surely makes sense.

Christoph, is that what you're proposing ?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
