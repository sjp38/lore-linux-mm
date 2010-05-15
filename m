Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 421806B01F2
	for <linux-mm@kvack.org>; Sat, 15 May 2010 12:12:36 -0400 (EDT)
Date: Sun, 16 May 2010 00:08:05 +0800
From: Shaohui Zheng <shaohui.zheng@intel.com>
Subject: Re: [RFC,2/7] NUMA Hotplug emulator
Message-ID: <20100515160805.GA23630@shaohui>
References: <20100513114544.GC2169@shaohui>
 <AANLkTikZiRw2w9hveCxA2XQp8SYs-4rYpH4BdZOns2CS@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <AANLkTikZiRw2w9hveCxA2XQp8SYs-4rYpH4BdZOns2CS@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Jaswinder Singh Rajput <jaswinderlinux@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Yinghai Lu <yinghai@kernel.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-kernel@vger.kernel.org, ak@linux.intel.co, fengguang.wu@intel.com, haicheng.li@linux.intel.com, shaohui.zheng@linux.intel.com
List-ID: <linux-mm.kvack.org>

On Sat, May 15, 2010 at 06:47:00PM +0530, Jaswinder Singh Rajput wrote:
> > +       if (hidden_num)
> 
> if (hidden_num) is not required, as next line's for statement is also
> doing the same thing.

Good catching, We will remove this statement in the formal patch. Thanks Jaswinder.

Have a nice day.

> 
> Thanks,
> --
> Jaswinder Singh.
> 
> > +               for (i = 0; i < hidden_num; i++) {
> > +                       int nid = num_nodes + i + 1;
> > +                       node_set(nid, node_possible_map);
> > +                       hidden_nodes[nid].start = hp_start + hp_size * i;
> > +                       hidden_nodes[nid].end = hp_start + hp_size * (i+1);
> > +                       node_set_hidden(nid);
> > +               }
> > +}

-- 
Thanks & Regards,
Shaohui

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
