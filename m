Date: Wed, 17 Oct 2007 14:19:13 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memory cgroup enhancements [0/5] intro
Message-Id: <20071017141913.a9fa27ad.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20071016112843.e4b8ebe3.akpm@linux-foundation.org>
References: <20071016191949.cd50f12f.kamezawa.hiroyu@jp.fujitsu.com>
	<471500EC.1080502@linux.vnet.ibm.com>
	<20071016112843.e4b8ebe3.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: balbir@linux.vnet.ibm.com, linux-mm@kvack.org, containers@lists.osdl.org, yamamoto@valinux.co.jp
List-ID: <linux-mm.kvack.org>

On Tue, 16 Oct 2007 11:28:43 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:
> > I would prefer these patches to go in once the fixes that you've posted
> > earlier have gone in (the migration fix series). I am yet to test the
> > migration fix per-se, but the series seemed quite fine to me. Andrew
> > could you please pick it up.
> 
> It's in my backlog somewhere.  I'm not paying much attention to things
> which don't look like 2.6.24 material at present...
> 
Ah, ok. I'll wait and keep this set as RFC for a while.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
