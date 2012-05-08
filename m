Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 103726B004D
	for <linux-mm@kvack.org>; Tue,  8 May 2012 07:57:31 -0400 (EDT)
Message-ID: <4FA909A2.2010203@parallels.com>
Date: Tue, 8 May 2012 08:55:14 -0300
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [RFC] slub: show dead memcg caches in a separate file
References: <1336070841-1071-1-git-send-email-glommer@parallels.com> <CABCjUKDuiN6bq6rbPjE7futyUwTPKsSFWHXCJ-OFf30tgq5WZg@mail.gmail.com> <4FA89348.6070000@parallels.com> <CAOJsxLHFS+B64qfhCg-9LPbggPoyvkBSnA8nZPRoV15eeRpi_w@mail.gmail.com>
In-Reply-To: <CAOJsxLHFS+B64qfhCg-9LPbggPoyvkBSnA8nZPRoV15eeRpi_w@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Suleiman Souhlal <suleiman@google.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org, Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@suse.cz>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Frederic Weisbecker <fweisbec@gmail.com>

On 05/08/2012 02:42 AM, Pekka Enberg wrote:
> On Tue, May 8, 2012 at 6:30 AM, Glauber Costa<glommer@parallels.com>  wrote:
>> But there is another aspect: those dead caches have one thing in common,
>> which is the fact that no new objects will ever be allocated on them. You
>> can't tune them, or do anything with them. I believe it is misleading to
>> include them in slabinfo.
>>
>> The fact that the caches change names - to append "dead" may also break
>> tools, if that is what you are concerned about.
>>
>> For all the above, I think a better semantics for slabinfo is to include the
>> active caches, and leave the dead ones somewhere else.
>
> Can these "dead caches" still hold on to physical memory? If so, they
> must appear in /proc/slabinfo.
Yes, if they didn't, I would show them nowhere, instead of in a separate 
file.

But okay, that's why I sent a separate RFC for that part.
I will revert this behavior.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
