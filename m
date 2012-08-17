Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id DE0596B006C
	for <linux-mm@kvack.org>; Fri, 17 Aug 2012 01:46:06 -0400 (EDT)
Message-ID: <502DD9E3.7060701@parallels.com>
Date: Fri, 17 Aug 2012 09:42:59 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 1/6] memcg: pass priority to prune_icache_sb()
References: <1345150430-30910-1-git-send-email-yinghan@google.com> <502DD663.2020504@parallels.com> <CALWz4iy=NR=yo5+-jj2nVqUiZtS+3866QiecUv3VGr2bkQONaQ@mail.gmail.com>
In-Reply-To: <CALWz4iy=NR=yo5+-jj2nVqUiZtS+3866QiecUv3VGr2bkQONaQ@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Greg Thelen <gthelen@google.com>, Christoph Lameter <cl@linux.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-mm@kvack.org

On 08/17/2012 09:44 AM, Ying Han wrote:
>> >
>> > Wouldn't it be possible to make sure that such inodes are in the end of
>> > the shrinkable list, so they are effectively left for last without
>> > messing with priorities?
> You mean rotate them to the end of the list? Thought that is what the
> patch end up doing.
> 
> --Ying

Yes, but not at shrink time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
