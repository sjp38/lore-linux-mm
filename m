Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id BC65E6B039F
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 18:31:47 -0400 (EDT)
Message-ID: <4FE8E632.70602@parallels.com>
Date: Tue, 26 Jun 2012 02:29:06 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 01/11] memcg: Make it possible to use the stock for more
 than one page.
References: <1340633728-12785-1-git-send-email-glommer@parallels.com> <1340633728-12785-2-git-send-email-glommer@parallels.com> <20120625174437.GC3869@google.com>
In-Reply-To: <20120625174437.GC3869@google.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Frederic Weisbecker <fweisbec@gmail.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, devel@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, Suleiman Souhlal <suleiman@google.com>

On 06/25/2012 09:44 PM, Tejun Heo wrote:
> Hey, Glauber.
>
> Just a couple nits.
>
> On Mon, Jun 25, 2012 at 06:15:18PM +0400, Glauber Costa wrote:
>> From: Suleiman Souhlal <ssouhlal@FreeBSD.org>
>
> It would be nice to explain why this is being done.  Just a simple
> statement like - "prepare for XXX" or "will be needed by XXX".

I picked this patch from Suleiman Souhlal, and tried to keep it as close 
as possible to his version.

But for the sake of documentation, I can do that, yes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
