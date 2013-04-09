Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id E2E526B0005
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 03:24:36 -0400 (EDT)
Message-ID: <5163C255.1010806@parallels.com>
Date: Tue, 9 Apr 2013 11:25:09 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 00/32] memcg-aware slab shrinking with lasers and numbers
References: <1365429659-22108-1-git-send-email-glommer@parallels.com> <20130408135128.a5a8b0e5b041f58f9e976bf7@linux-foundation.org>
In-Reply-To: <20130408135128.a5a8b0e5b041f58f9e976bf7@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Dave Shrinnker <david@fromorbit.com>, Serge Hallyn <serge.hallyn@canonical.com>, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, hughd@google.com, linux-fsdevel@vger.kernel.org, containers@lists.linux-foundation.org, Greg Thelen <gthelen@google.com>

On 04/09/2013 12:51 AM, Andrew Morton wrote:
> On Mon,  8 Apr 2013 18:00:27 +0400 Glauber Costa <glommer@parallels.com> wrote:
> 
>> Cc: Dave Shrinnker <david@fromorbit.com>
> 
> I keep on receiving emails from people who claim they can fix this.
> 

=)

>> This patchset implements targeted shrinking for memcg when kmem limits are
>> present. So far, we've been accounting kernel objects but failing allocations
>> when short of memory. This is because our only option would be to call the
>> global shrinker, depleting objects from all caches and breaking isolation.
> 
> This is a fine-looking patchset and it even has some acks and reviews. 
> But it's huuuuge and we're at -rc6 and I've been offline for a week and
> have 975 emails in my to-apply folder.
> 
> So, err, I think I'll bestow upon everyone some additional time to
> review the code ;)  Please resend for -rc1?
> 
Sure. This was still a mostly asynchronous submission. I also believe I
would have to rebase on top of Li Zefan's patchset that made some very
important refcount cleanups in memcg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
