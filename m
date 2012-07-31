Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010asp103.postini.com [74.125.245.223])
	by kanga.kvack.org (Postfix) with SMTP id 98EDB6B0088
	for <linux-mm@kvack.org>; Tue, 31 Jul 2012 13:26:03 -0400 (EDT)
Message-ID: <50180A42.2050806@parallels.com>
Date: Tue, 31 Jul 2012 20:39:30 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 00/10] memcg kmem limitation - slab.
References: <1343227101-14217-1-git-send-email-glommer@parallels.com> <20120731163027.GE17078@somewhere.redhat.com>
In-Reply-To: <20120731163027.GE17078@somewhere.redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Frederic Weisbecker <fweisbec@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, devel@openvz.org, cgroups@vger.kernel.org

On 07/31/2012 08:30 PM, Frederic Weisbecker wrote:
> On Wed, Jul 25, 2012 at 06:38:11PM +0400, Glauber Costa wrote:
>> Hi,
>>
>> This is the slab part of the kmem limitation mechanism in its last form.  I
>> would like to have comments on it to see if we can agree in its form. I
>> consider it mature, since it doesn't change much in essence over the last
>> forms. However, I would still prefer to defer merging it and merge the
>> stack-only patchset first (even if inside the same merge window). That patchset
>> contains most of the infrastructure needed here, and merging them separately
>> would not only reduce the complexity for reviewers, but allow us a chance to
>> have independent testing on them both. I would also likely benefit from some
>> extra testing, to make sure the recent changes didn't introduce anything bad.
> 
> What is the status of the stack-only limitation patchset BTW? Does anybody oppose
> to its merging?
> 
> Thanks.
> 
Andrew said he would like to see the slab patches in a relatively mature
state first.

I do believe they are in such a state. There are bugs, that I am working
on - but I don't see anything that would change them significantly at
this point.

If Andrew is happy with what he saw in this thread, I could post those
again.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
