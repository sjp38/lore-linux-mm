Date: Thu, 19 Jul 2007 23:51:57 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUGFIX]{PATCH] flush icache on ia64 take2
Message-Id: <20070719235157.9715baff.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <469F71E7.4050200@bull.net>
References: <20070706112901.16bb5f8a.kamezawa.hiroyu@jp.fujitsu.com>
	<20070719155632.7dbfb110.kamezawa.hiroyu@jp.fujitsu.com>
	<469F5372.7010703@bull.net>
	<20070719220118.73f40346.kamezawa.hiroyu@jp.fujitsu.com>
	<469F71E7.4050200@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tony.luck@intel.com, nickpiggin@yahoo.com.au, mike@stroyan.net, dmosberger@gmail.com, y-goto@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Thu, 19 Jul 2007 16:15:03 +0200
Zoltan Menyhart <Zoltan.Menyhart@bull.net> wrote:

> We may have, say 1 Gbyte / sec local i/o activity (using some RAIDs).
> Assume a few % of this 1 Gbyte is the program execution, or program swap in.
> It gives some hundreds of new exec pages / sec =>
> some msec-s can be lost each sec.
> 
> I can agree that it should not be a big deal :-)
> 
Hmm...but the current code flushes the page. just do it in "lazy" way.
much difference ?

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
