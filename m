Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mA719qo4028983
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 7 Nov 2008 10:09:52 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B04D545DD85
	for <linux-mm@kvack.org>; Fri,  7 Nov 2008 10:09:51 +0900 (JST)
Received: from s7.gw.fujitsu.co.jp (s7.gw.fujitsu.co.jp [10.0.50.97])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6B46645DD7D
	for <linux-mm@kvack.org>; Fri,  7 Nov 2008 10:09:51 +0900 (JST)
Received: from s7.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s7.gw.fujitsu.co.jp (Postfix) with ESMTP id 399CB1DB8045
	for <linux-mm@kvack.org>; Fri,  7 Nov 2008 10:09:51 +0900 (JST)
Received: from ml11.s.css.fujitsu.com (ml11.s.css.fujitsu.com [10.249.87.101])
	by s7.gw.fujitsu.co.jp (Postfix) with ESMTP id E28121DB803E
	for <linux-mm@kvack.org>; Fri,  7 Nov 2008 10:09:50 +0900 (JST)
Date: Fri, 7 Nov 2008 10:09:15 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [linux-pm] [PATCH] hibernation should work ok with memory
 hotplug
Message-Id: <20081107100915.6c525512.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.44L0.0811060943480.2456-100000@iolanthe.rowland.org>
References: <20081106095314.8e65f443.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.44L0.0811060943480.2456-100000@iolanthe.rowland.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Stern <stern@rowland.harvard.edu>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, Nigel Cunningham <ncunningham@crca.org.au>, Tolentino <matthew.e.tolentino@intel.com>, Hansen <haveblue@us.ibm.com>, linux-pm@lists.osdl.org, Matt@smtp1.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave@smtp1.linux-foundation.org, Mel Gorman <mel@skynet.ie>, Andy@smtp1.linux-foundation.org, Whitcroft <apw@shadowen.org>, Yasunori Goto <y-goto@jp.fujitsu.com>, pavel@suse.cz, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 6 Nov 2008 09:47:12 -0500 (EST)
Alan Stern <stern@rowland.harvard.edu> wrote:

> On Thu, 6 Nov 2008, KAMEZAWA Hiroyuki wrote:
> 
> > Hmm, people tend to make crazy hardware, oh yes. the pc may fly in
> > the sky with rocket engine.
> 
> This isn't crazy at all.  I am currently working on an experiment 
> called RAISE (Rapid Acquisition Imaging Spectrograph Experiment) that 
> involves flying a rocket above the Earth's atmosphere to make 
> measurements of the Sun.  The experiments in this rocket will be 
> controlled by a computer running Linux.  See
> 
> 	http://www.swri.org/3pubs/ttoday/Spring06/Solar.htm
> 
> for a slightly out-of-date description.
> 

interesitng :)

-Kame

> Alan Stern
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
