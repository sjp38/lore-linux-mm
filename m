Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id BDE89900137
	for <linux-mm@kvack.org>; Mon, 29 Aug 2011 19:30:07 -0400 (EDT)
Date: Tue, 30 Aug 2011 01:30:01 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] thp: tail page refcounting fix #4
Message-ID: <20110829233001.GM4051@redhat.com>
References: <CANN689HE=TKyr-0yDQgXEoothGJ0Cw0HLB2iOvCKrOXVF2DNww@mail.gmail.com>
 <20110824000914.GH23870@redhat.com>
 <20110824002717.GI23870@redhat.com>
 <20110824133459.GP23870@redhat.com>
 <20110826062436.GA5847@google.com>
 <20110826161048.GE23870@redhat.com>
 <20110826185430.GA2854@redhat.com>
 <20110827094152.GA16402@google.com>
 <20110827173421.GA2967@redhat.com>
 <CANN689G4HowkFC7BG69F-PJMne5Mhs51O=KgmmJUjiXfG-o9BQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CANN689G4HowkFC7BG69F-PJMne5Mhs51O=KgmmJUjiXfG-o9BQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Mon, Aug 29, 2011 at 03:40:07PM -0700, Michel Lespinasse wrote:
> Looks great.

Thanks!

> I think some page_mapcount call sites would be easier to read if you
> took on my tail_page_count() suggestion (so we can casually see it's a
> refcount rather than mapcount). But you don't have to do it if you
> don't think it helps. I'm happy enough with the code already :)

I initially tried to do it but I wanted it in internal.h (it's really
an internal thing not mean for any driver whatsoever) but then the
gup.c files wouldn't see it, so I wasn't sure how to proceed and I
dropped it. It's still possible to do it later...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
