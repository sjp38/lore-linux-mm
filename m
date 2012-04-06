Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 24BEA6B004A
	for <linux-mm@kvack.org>; Fri,  6 Apr 2012 03:16:43 -0400 (EDT)
Received: by pbcup15 with SMTP id up15so2781342pbc.14
        for <linux-mm@kvack.org>; Fri, 06 Apr 2012 00:16:42 -0700 (PDT)
Message-ID: <4F7E9854.1020904@gmail.com>
Date: Fri, 06 Apr 2012 15:16:36 +0800
From: "gnehzuil.lzheng@gmail.com" <gnehzuil.lzheng@gmail.com>
MIME-Version: 1.0
Subject: Re: mapped pagecache pages vs unmapped pages
References: <37371333672160@webcorp7.yandex-team.ru>
In-Reply-To: <37371333672160@webcorp7.yandex-team.ru>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexey Ivanov <rbtz@yandex-team.ru>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 04/06/2012 08:29 AM, Alexey Ivanov wrote:

> In progress of migration from FreeBSD to Linux and we found some strange behavior: periodically running tasks (like rsync/p2p deployment) evict mapped pages from memory.
> 
> From my little research I've found following lkml thread:
> https://lkml.org/lkml/2008/6/11/278
> And more precisely this commit: https://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=4f98a2fee8acdb4ac84545df98cccecfd130f8db
> which along with splitting LRU into "anon" and "file" removed support of reclaim_mapped.
> 
> Is there a knob to prioritize mapped memory over unmapped (without modifying all apps to use O_DIRECT/fadvise/madvise or mlocking our data in memory) or at least some way to change proportion of Active(file)/Inactive(file)?
> 


Hi Alexey,

Cc to linux-mm mailing list.

I have met the similar problem and I have sent a mail to discuss it.
Maybe it can help you
(http://marc.info/?l=linux-mm&m=132947026019538&w=2).

Now Konstantin has sent a patch set to try to expand vm_flags from 32
bit to 64 bit.  Then we can add the new flag into vm_flags and
prioritize mmaped pages in madvise(2).

Regards,
Zheng

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
