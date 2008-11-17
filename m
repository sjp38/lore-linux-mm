Message-ID: <4921BDC5.4090303@redhat.com>
Date: Mon, 17 Nov 2008 13:53:57 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] vmscan: fix get_scan_ratio comment
References: <20081115181748.3410.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20081115210039.537f59f5.akpm@linux-foundation.org> <alpine.LFD.2.00.0811161013270.3468@nehalem.linux-foundation.org> <49208E9A.5080801@redhat.com> <20081116204720.1b8cbe18.akpm@linux-foundation.org> <20081117153012.51ece88f.kamezawa.hiroyu@jp.fujitsu.com> <2f11576a0811162239w58555c6dq8a61ec184b22bd52@mail.gmail.com> <20081117155417.5cc63907.kamezawa.hiroyu@jp.fujitsu.com> <alpine.LFD.2.00.0811170802010.3468@nehalem.linux-foundation.org> <alpine.LFD.2.00.0811170830320.3468@nehalem.linux-foundation.org> <4921A1AF.1070909@redhat.com> <alpine.LFD.2.00.0811170904160.3468@nehalem.linux-foundation.org> <4921A706.9030501@redhat.com> <alpine.LFD.2.00.0811170932390.3468@nehalem.linux-foundation.org>
In-Reply-To: <alpine.LFD.2.00.0811170932390.3468@nehalem.linux-foundation.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Gene Heskett <gene.heskett@gmail.com>
List-ID: <linux-mm.kvack.org>

Linus Torvalds wrote:

> Anyway, without quoting, the thing is - your fix isn't any better. The 
> more interesting part is how the fractions get combined, and that is 
> indeed approximately "anon% = anon / (anon + file)".

Well, the "anon" and "file" in that calculation are the
scanned/rotated ratios for anon and file pages, not the
sizes of the lists.

> So you in many ways made the comment worse. It wasn't good before, but 
> it's still not good, and now it comments on the part that isn't even 
> interesting (ie it comments the _trivial_ fractional part)

How about something like the following: ?

/*
  * The amount of pressure on anon vs file pages is inversely
  * proportional to the fraction of recently scanned pages on
  * each list that were recently referenced and in active use.
  */

(I'll mail the next patches out with claws-mail - silly thunderbird)

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
