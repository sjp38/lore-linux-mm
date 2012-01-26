Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id F2D976B004F
	for <linux-mm@kvack.org>; Thu, 26 Jan 2012 05:46:45 -0500 (EST)
Message-ID: <4F212F09.4090802@5t9.de>
Date: Thu, 26 Jan 2012 11:46:33 +0100
From: Lutz Vieweg <lvml@5t9.de>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: preallocate page before lock_page at filemap COW.
 (WasRe: [PATCH V2] mm: Do not keep page locked during page fault while charging
 it for memcg
References: <20110622120635.GB14343@tiehlicka.suse.cz> <20110622121516.GA28359@infradead.org> <20110622123204.GC14343@tiehlicka.suse.cz> <20110623150842.d13492cd.kamezawa.hiroyu@jp.fujitsu.com> <20110623074133.GA31593@tiehlicka.suse.cz> <20110623170811.16f4435f.kamezawa.hiroyu@jp.fujitsu.com> <20110623090204.GE31593@tiehlicka.suse.cz> <20110623190157.1bc8cbb9.kamezawa.hiroyu@jp.fujitsu.com> <20110624075742.GA10455@tiehlicka.suse.cz> <BANLkTin7TbK1dNjPG6jz_FaJy-QgOjDJaA@mail.gmail.com> <20110712094841.GC10552@tiehlicka.suse.cz>
In-Reply-To: <20110712094841.GC10552@tiehlicka.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Mel Gorman <mgorman@suse.de>

On 07/12/2011 11:48 AM, Michal Hocko wrote:
> Is there any intereset in discussing this or the email just got lost?
> Just for reference preallocation patch from Kamezawa is already in the
> Andrew's tree.

It's been a long time since this discussion, I just wanted to add
that I've been recently able to confirm the ability of memcg
to prevent single users from DOSing a system by "make -j" - in
a real-world scenario (using linux-3.2.1).

So thanks to all who contributed to the solution in whatever way :-)

(A minor issue remained: The kernel is very verbose when
killing tasks due to memcg restrictions. In fork-bomb like
scenarios, this can lead to high resource utilization for
syslog et al.)

Regards,

Lutz Vieweg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
