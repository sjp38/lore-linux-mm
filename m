Date: Tue, 28 Aug 2007 10:21:28 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: [PATCH/RFC]  Add node 'states' sysfs class attribute - V2
In-Reply-To: <20070828100633.8150.Y-GOTO@jp.fujitsu.com>
References: <1188248528.5952.95.camel@localhost> <20070828100633.8150.Y-GOTO@jp.fujitsu.com>
Message-Id: <20070828101925.8152.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm <linux-mm@kvack.org>, clameter@sgi.com, mel@skynet.ie, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

> > Add a sysfs class attribute file to /sys/devices/system/node
> > to display node state masks.
> 
> IIRC, sysfs has the policy that each file shows only one value,
> and all files keep it.
> 
> But, this states file shows 4 values.
> I think you should  make 4 files which show just one value like
> followings.
>   /sys/devices/system/node/possible
>                           /online
>                           /has_normal_memory
>                           /has_cpu

Oh, I found it discussed in other thread....
Sorry for noise..



-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
