Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id lB4JfQEh029357
	for <linux-mm@kvack.org>; Tue, 4 Dec 2007 14:41:26 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lB4JfFe8100348
	for <linux-mm@kvack.org>; Tue, 4 Dec 2007 12:41:18 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lB4JfFln021383
	for <linux-mm@kvack.org>; Tue, 4 Dec 2007 12:41:15 -0700
Subject: Re: [RFC PATCH] LTTng instrumentation mm (updated)
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20071204192537.GC31752@Krystal>
References: <20071128140953.GA8018@Krystal>
	 <1196268856.18851.20.camel@localhost> <20071129023421.GA711@Krystal>
	 <1196317552.18851.47.camel@localhost> <20071130161155.GA29634@Krystal>
	 <1196444801.18851.127.camel@localhost> <20071130170516.GA31586@Krystal>
	 <1196448122.19681.16.camel@localhost> <20071130191006.GB3955@Krystal>
	 <y0mve7ez2y3.fsf@ton.toronto.redhat.com>  <20071204192537.GC31752@Krystal>
Content-Type: text/plain
Date: Tue, 04 Dec 2007 11:40:59 -0800
Message-Id: <1196797259.6073.17.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Cc: "Frank Ch. Eigler" <fche@redhat.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mbligh@google.com
List-ID: <linux-mm.kvack.org>

On Tue, 2007-12-04 at 14:25 -0500, Mathieu Desnoyers wrote:
> 
> - I also dump the equivalent of /proc/swaps (with kernel internal
>   information) at trace start to know what swap files are currently
>   used.

What about just enhancing /proc/swaps so that this information can be
useful to people other than those doing traces?

Now that we have /proc/$pid/pagemap, we expose some of the same
information about which userspace virtual addresses are stored where and
in which swapfile.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
