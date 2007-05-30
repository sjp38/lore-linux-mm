Date: Wed, 30 May 2007 13:09:11 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Make dynamic/run-time configuration of zonelist order
 configurable
Message-Id: <20070530130911.431d5f6f.akpm@linux-foundation.org>
In-Reply-To: <1180554142.5850.90.camel@localhost>
References: <1180468121.5067.64.camel@localhost>
	<20070530111212.095350d2.akpm@linux-foundation.org>
	<1180554142.5850.90.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm <linux-mm@kvack.org>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nishanth Aravamudan <nacc@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Wed, 30 May 2007 15:42:22 -0400
Lee Schermerhorn <Lee.Schermerhorn@hp.com> wrote:

> But, before I go and rework it against the current mm
> tree and then rebase the hugetlb fix on that, could you offer an opinion
> either way, whether it's worth the effort and a new Kconfig option to
> attempt to give back this amount init code/data?  I recall you making
> noise about the zonelist order patch being "a lot of code" when Kame
> first posted it.

The concern with a "lot of code" is 99% about complexity, reliability and
maintainability and only 1% about RAM usage.

This stuff is mainly a NUMA/SMP thing, isn't it?  If so, a couple of k is
neither here nor there.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
