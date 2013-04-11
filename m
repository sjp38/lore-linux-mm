Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 9FF286B0006
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 11:01:14 -0400 (EDT)
Received: by mail-vb0-f54.google.com with SMTP id w16so1335761vbf.13
        for <linux-mm@kvack.org>; Thu, 11 Apr 2013 08:01:13 -0700 (PDT)
Message-ID: <5166D037.6040405@gmail.com>
Date: Thu, 11 Apr 2013 11:01:11 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC v7 00/11] Support vrange for anonymous page
References: <1363073915-25000-1-git-send-email-minchan@kernel.org> <5165CA22.6080808@gmail.com> <20130411065546.GA10303@blaptop> <5166643E.6050704@gmail.com> <20130411080243.GA12626@blaptop> <5166712C.7040802@gmail.com> <20130411083146.GB12626@blaptop>
In-Reply-To: <20130411083146.GB12626@blaptop>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michael Kerrisk <mtk.manpages@gmail.com>, Arun Sharma <asharma@fb.com>, John Stultz <john.stultz@linaro.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Jason Evans <je@fb.com>, sanjay@google.com, Paul Turner <pjt@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michel Lespinasse <walken@google.com>, Andrew Morton <akpm@linux-foundation.org>

>>>> and adding new syscall invokation is unwelcome.
>>>
>>> Sure. But one more system call could be cheaper than page-granuarity
>>> operation on purged range.
>>
>> I don't think vrange(VOLATILE) cost is the related of this discusstion.
>> Whether sending SIGBUS or just nuke pte, purge should be done on vmscan,
>> not vrange() syscall.
> 
> Again, please see the MADV_FREE. http://lwn.net/Articles/230799/
> It does changes pte and page flags on all pages of the range through
> zap_pte_range. So it would make vrange(VOLASTILE) expensive and
> the bigger cost is, the bigger range is.

This haven't been crossed my mind. now try_to_discard_one() insert vrange
for making SIGBUS. then, we can insert pte_none() as the same cost too. Am
I missing something?

I couldn't imazine why pte should be zapping on vrange(VOLATILE).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
