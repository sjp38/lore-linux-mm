Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id EE1E96B0070
	for <linux-mm@kvack.org>; Mon, 22 Oct 2012 18:38:46 -0400 (EDT)
Date: Mon, 22 Oct 2012 15:38:45 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3 0/9] bugfix for memory hotplug
Message-Id: <20121022153845.4e059984.akpm@linux-foundation.org>
In-Reply-To: <50811FE1.4080606@jp.fujitsu.com>
References: <1350629202-9664-1-git-send-email-wency@cn.fujitsu.com>
	<508109F2.1080402@jp.fujitsu.com>
	<50810D14.8020609@jp.fujitsu.com>
	<50811336.7070704@cn.fujitsu.com>
	<50811FE1.4080606@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: Wen Congyang <wency@cn.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com

On Fri, 19 Oct 2012 18:39:45 +0900
Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com> wrote:

> 2012/10/19 17:45, Wen Congyang wrote:
> > At 10/19/2012 04:19 PM, Yasuaki Ishimatsu Wrote:
> >> 2012/10/19 17:06, Yasuaki Ishimatsu wrote:
> >>> Hi Wen,
> >>>
> >>> Some bug fix patches have been merged into linux-next.
> >>> So the patches confuse me.
> > 
> > Sorry, I don't check linux-next tree.
> > 
> >>
> >> The following patches have been already merged into linux-next
> >> and mm-tree as long as I know.
> >>
> >>>> Wen Congyang (6):
> >>>>      clear the memory to store struct page
> >>
> >>
> >>>>      memory-hotplug: skip HWPoisoned page when offlining pages
> >>
> >> mm-tree
> > 
> > Hmm, I don't find this patch in this URL:
> > http://www.ozlabs.org/~akpm/mmotm/broken-out/
> > 
> > Do I miss something?
> 
> But Andrew announced that the patch was merged in mm-tree.
> And you received the announcement.

mmotm is updated less frequently than http://ozlabs.org/~akpm/mmots/ so
it's best to check mmots to find out what's in there.  Even mmots is
lagging recently, because of ongoing sched-numa damage (grump).  But
that has all improved lately so we should be getting back on track.

And yes, I merged
memory-hotplug-skip-hwpoisoned-page-when-offlining-pages.patch on 18
October.

The memory hotplug patching is somewhat confusing at present, so
thanks for checking - please continue to do so!  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
