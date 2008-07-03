Date: Thu, 03 Jul 2008 18:38:52 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [mmotm] build failure on x86_64 pci-calgary_64.c
In-Reply-To: <20080703090722.GA17350@elte.hu>
References: <20080703174027.D6D7.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20080703090722.GA17350@elte.hu>
Message-Id: <20080703182244.D6DC.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Yinghai Lu <yhlu.kernel@gmail.com>, Li Zefan <lizf@cn.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, npiggin@suse.de, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik Van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

> > I guess below commit or related commit is doubtfully.
> > 
> > :commit 1b1b18f0bf62ec808784002382f2b5833701afda
> > :Author: Yinghai Lu <yhlu.kernel@gmail.com>
> > :Date:   Tue Jun 24 22:14:09 2008 -0700
> > :
> > :    x86: remove end_pfn in 64bit
> > :
> > :    and use max_pfn directly.
> > :
> > :    Signed-off-by: Yinghai Lu <yhlu.kernel@gmail.com>
> > :    Signed-off-by: Ingo Molnar <mingo@elte.hu>
> 
> no.
> 
> this a linux-next integration artifact AFAICT, there's no such build 
> failure in the x86 tree.
> 
> what happened is that the x86 tree got rid of end_pfn, the PCI tree grew 
> one more reference to it and it was not fixed up.

sorry ;)

btw: I confirmed 2.6.26-rc8-mm1 (contain Andrew's end_pfx fix) works well.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
