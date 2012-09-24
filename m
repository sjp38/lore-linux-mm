Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id E0AB26B002B
	for <linux-mm@kvack.org>; Mon, 24 Sep 2012 04:19:14 -0400 (EDT)
Message-ID: <506016B7.8010600@parallels.com>
Date: Mon, 24 Sep 2012 12:15:51 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 00/16] slab accounting for memcg
References: <1347977530-29755-1-git-send-email-glommer@parallels.com> <20120921204619.GR7264@google.com>
In-Reply-To: <20120921204619.GR7264@google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, devel@openvz.org, linux-mm@kvack.org, Suleiman Souhlal <suleiman@google.com>, Frederic Weisbecker <fweisbec@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>

On 09/22/2012 12:46 AM, Tejun Heo wrote:
> Hello,
> 
> On Tue, Sep 18, 2012 at 06:11:54PM +0400, Glauber Costa wrote:
>> This is a followup to the previous kmem series. I divided them logically
>> so it gets easier for reviewers. But I believe they are ready to be merged
>> together (although we can do a two-pass merge if people would prefer)
>>
>> Throwaway git tree found at:
>>
>> 	git://git.kernel.org/pub/scm/linux/kernel/git/glommer/memcg.git kmemcg-slab
>>
>> There are mostly bugfixes since last submission.
>>
>> For a detailed explanation about this series, please refer to my previous post
>> (Subj: [PATCH v3 00/13] kmem controller for memcg.)
> 
> In general, things look good to me.  I think the basic approach is
> manageable and does a decent job of avoiding introducing complications
> on the usual code paths.
> 
> Pekka seems generally happy with the approach too.  Christoph, what do
> you think?
> 
> Thanks.
> 
I myself think that while the approach is okay, this would need one or
two more versions for us to sort out some issues that are still remaining.

I'd very much like to have the kmemcg-stack series seeing its way
forward first. Mel Gorman said he would try his best to review it his
week, and I don't plan to resubmit anything before that.

After that, I plan to rebase at least this one again.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
