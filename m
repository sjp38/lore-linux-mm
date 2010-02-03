Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id B69D16B0047
	for <linux-mm@kvack.org>; Wed,  3 Feb 2010 16:22:15 -0500 (EST)
From: Lubos Lunak <l.lunak@suse.cz>
Subject: Re: Improving OOM killer
Date: Wed, 3 Feb 2010 22:22:15 +0100
References: <201002012302.37380.l.lunak@suse.cz> <201002031310.28271.l.lunak@suse.cz> <20100203122526.GG19641@balbir.in.ibm.com>
In-Reply-To: <20100203122526.GG19641@balbir.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <201002032222.15238.l.lunak@suse.cz>
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Jiri Kosina <jkosina@suse.cz>
List-ID: <linux-mm.kvack.org>

On Wednesday 03 of February 2010, Balbir Singh wrote:
> * Lubos Lunak <l.lunak@suse.cz> [2010-02-03 13:10:27]:
> > On Wednesday 03 of February 2010, Balbir Singh wrote:
> > > 2. RSS alone is not sufficient, RSS does not account for shared pages,
> > > so we ideally need something like PSS.
> >
> >  Just to make sure I understand what you mean with "RSS does not account
> > for shared pages" - you say that if a page is shared by 4 processes, then
> > when calculating badness for them, only 1/4 of the page should be counted
> > for each? Yes, I suppose so, that makes sense.
>
> Yes, that is what I am speaking of
>
> > That's more like fine-tunning at
> > this point though, as long as there's no agreement that moving away from
> > VmSize is an improvement.
>
> There is no easy way to calculate the Pss today without walking the
> page tables, but some simplification there will make it a better and a
> more accurate metric.

 OOM should be a rare situation, so doing a little amount of counting 
shouldn't be a big deal. Especially if the machine is otherwise busy waiting 
for the HDD paging stuff out and in again and has plenty of CPU time to 
waste.

-- 
 Lubos Lunak
 openSUSE Boosters team, KDE developer
 l.lunak@suse.cz , l.lunak@kde.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
