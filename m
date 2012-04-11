Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id C9E876B004D
	for <linux-mm@kvack.org>; Wed, 11 Apr 2012 15:04:26 -0400 (EDT)
Message-ID: <4F85D53B.1070806@parallels.com>
Date: Wed, 11 Apr 2012 16:02:19 -0300
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH] remove BUG() in possible but rare condition
References: <1334167824-19142-1-git-send-email-glommer@parallels.com> <20120411184845.GA24831@tiehlicka.suse.cz> <CA+55aFx1GMWGgh0sTAzvvVSzPQsQ_4NKeaNv1zpKrP4fg1dG+Q@mail.gmail.com>
In-Reply-To: <CA+55aFx1GMWGgh0sTAzvvVSzPQsQ_4NKeaNv1zpKrP4fg1dG+Q@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, devel@openvz.org, linux-mm@kvack.org, cgroups@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, Greg Thelen <gthelen@google.com>, Suleiman Souhlal <suleiman@google.com>, Andrew Morton <akpm@linux-foundation.org>

On 04/11/2012 03:57 PM, Linus Torvalds wrote:
> On Wed, Apr 11, 2012 at 11:48 AM, Michal Hocko<mhocko@suse.cz>  wrote:
>>
>> I am not familiar with the code much but a trivial call chain walk up to
>> write_dev_supers (in btrfs) shows that we do not check for the return value
>> from __getblk so we would nullptr and there might be more.
>> I guess these need some treat before the BUG might be removed, right?
>
> Well, realistically, isn't BUG() as bad as a NULL pointer dereference?
>
> Do you care about the exact message on the screen when your machine dies?
Not particular, but I don't see why (I might be wrong) it would 
necessarily lead to a NULL pointer dereference.

At least in my test cases, after turning this to a WARN (to make sure it 
was still being hit), the machine could go on just fine.

I was running this in a container system, with restricted memory. After
killing the container - at least in my ext4 system - everything seemed 
as happy as ever.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
