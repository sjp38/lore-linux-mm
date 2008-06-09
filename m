Date: Mon, 9 Jun 2008 18:55:05 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 0/2] memcg: hierarchy support (v3)
Message-Id: <20080609185505.4259019f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <484CF82E.1010508@linux.vnet.ibm.com>
References: <20080604135815.498eaf82.kamezawa.hiroyu@jp.fujitsu.com>
	<484CF82E.1010508@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "menage@google.com" <menage@google.com>, "xemul@openvz.org" <xemul@openvz.org>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

On Mon, 09 Jun 2008 15:00:22 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> KAMEZAWA Hiroyuki wrote:
> > Hi, this is third version.
> > 
> > While small changes in codes, the whole _tone_ of code is changed.
> > I'm not in hurry, any comments are welcome.
> > 
> > based on 2.6.26-rc2-mm1 + memcg patches in -mm queue.
> > 
> 
> Hi, Kamezawa-San,
> 
> Sorry for the delay in responding. Like we discussed last time, I'd prefer a
> shares based approach for hierarchial memcg management. I'll review/try these
> patches and provide more feedback.
> 
Hi,

I'm now totally re-arranging patches, so just see concepts.

In previous e-mail, I thought that there was a difference between 'your share'
and 'my share'. So, please explain again ? 

My 'share' has following characteristics.

  - work as soft-limit. not hard-limit.
  - no limit when there are not high memory pressure.
  - resource usage will be proportionally fair to each group's share (priority)
    under memory pressure.

If you want to work on this, I can stop this for a while and do other important
patches, like background reclaim, mlock limitter, guarantee, etc.. because my 
priority to hierarchy is not very high (but it seems better to do this before
other misc works, so I did.). 

Anyway, we have to test the new LRU (RvR LRU) at first in the next -mm ;)

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
