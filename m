Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 29C5B6B005A
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 08:31:01 -0400 (EDT)
Message-ID: <4FEAFC5E.4050104@parallels.com>
Date: Wed, 27 Jun 2012 16:28:14 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: Fork bomb limitation in memcg WAS: Re: [PATCH 00/11] kmem controller
 for memcg: stripped down version
References: <1340633728-12785-1-git-send-email-glommer@parallels.com> <20120625162745.eabe4f03.akpm@linux-foundation.org> <4FE9621D.2050002@parallels.com> <20120626145539.eeeab909.akpm@linux-foundation.org> <4FEAD260.4000603@parallels.com> <20120627122924.GD20638@somewhere.redhat.com>
In-Reply-To: <20120627122924.GD20638@somewhere.redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Frederic Weisbecker <fweisbec@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, devel@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, Tejun Heo <tj@kernel.org>, Rik van Riel <riel@redhat.com>, Daniel Lezcano <daniel.lezcano@linaro.org>, Kay Sievers <kay.sievers@vrfy.org>, Lennart Poettering <lennart@poettering.net>, "Kirill A. Shutemov" <kirill@shutemov.name>, Kir Kolyshkin <kir@parallels.com>

On 06/27/2012 04:29 PM, Frederic Weisbecker wrote:
> On Wed, Jun 27, 2012 at 01:29:04PM +0400, Glauber Costa wrote:
>> On 06/27/2012 01:55 AM, Andrew Morton wrote:
>>>> I can't speak for everybody here, but AFAIK, tracking the stack through
>>>> the memory it used, therefore using my proposed kmem controller, was an
>>>> idea that good quite a bit of traction with the memcg/memory people.
>>>> So here you have something that people already asked a lot for, in a
>>>> shape and interface that seem to be acceptable.
>>>
>>> mm, maybe.  Kernel developers tend to look at code from the point of
>>> view "does it work as designed", "is it clean", "is it efficient", "do
>>> I understand it", etc.  We often forget to step back and really
>>> consider whether or not it should be merged at all.
>>>
>>> I mean, unless the code is an explicit simplification, we should have
>>> a very strong bias towards "don't merge".
>>
>> Well, simplifications are welcome - this series itself was
>> simplified beyond what I thought initially possible through the
>> valuable comments
>> of other people.
>>
>> But of course, this adds more complexity to the kernel as a whole.
>> And this is true to every single new feature we may add, now or in
>> the
>> future.
>>
>> What I can tell you about this particular one, is that the justification
>> for it doesn't come out of nowhere, but from a rather real use case that
>> we support and maintain in OpenVZ and our line of products for years.
> 
> Right and we really need a solution to protect against forkbombs in LXC.
Small correction: In containers. LXC is not the only one out there =p


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
