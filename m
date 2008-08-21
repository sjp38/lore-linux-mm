Received: by wr-out-0506.google.com with SMTP id c30so36016wra.14
        for <linux-mm@kvack.org>; Thu, 21 Aug 2008 08:18:28 -0700 (PDT)
Message-ID: <a2776ec50808210818n74c09003s98ee8e7bd8e73951@mail.gmail.com>
Date: Thu, 21 Aug 2008 17:18:27 +0200
From: righi.andrea@gmail.com
Reply-To: righiandr@users.sourceforge.net
Subject: Re: [discuss] memrlimit - potential applications that can use
In-Reply-To: <20080821164339.679212b2.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <48AA73B5.7010302@linux.vnet.ibm.com>
	 <1219161525.23641.125.camel@nimitz>
	 <48AAF8C0.1010806@linux.vnet.ibm.com>
	 <1219167669.23641.156.camel@nimitz>
	 <48ABD545.8010209@linux.vnet.ibm.com>
	 <1219249757.8960.22.camel@nimitz>
	 <48ACE040.2030807@linux.vnet.ibm.com>
	 <20080821164339.679212b2.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: balbir@linux.vnet.ibm.com, Dave Hansen <dave@linux.vnet.ibm.com>, Paul Menage <menage@google.com>, Dave Hansen <haveblue@us.ibm.com>, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, linux kernel mailing list <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On 8/21/08, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> I'm sorry I miss the point. My concern on memrlimit (for overcommiting) is
> that
> it's not fair because an application which get -ENOMEM at mmap() is just
> someone
> unlucky. I think it's better to trigger some notifier to application or
> daemon
> rather than return -ENOMEM at mmap(). Notification like "Oh, it seems the
> VSZ
> of total application exceeds the limit you set. Although you can continue
> your
> operation, it's recommended that you should fix up the  situation".
> will be good.

-ENOMEM should be considered by applications like "try again" (maybe
-EAGAIN would be more appropriate). When the notification of the
out-of-virtual-memory event occurs the dedicated userspace daemon can
do ehm... something... to resolve the situation. Just like the OOM
handling in userspace. Similar issues, but a common solution could
resolve both problems.

-Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
