Date: Fri, 22 Feb 2008 19:34:40 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] Clarify mem_cgroup lock handling and avoid races.
Message-Id: <20080222193440.0bda7bde.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0802221018210.25455@blonde.site>
References: <20080219215431.1aa9fa8a.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0802191449490.6254@blonde.site>
	<20080220.152753.98212356.taka@valinux.co.jp>
	<20080220155049.094056ac.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0802220916290.18145@blonde.site>
	<20080222190742.e8c03763.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0802221018210.25455@blonde.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Hirokazu Takahashi <taka@valinux.co.jp>, linux-mm@kvack.org, balbir@linux.vnet.ibm.com, yamamoto@valinux.co.jp, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On Fri, 22 Feb 2008 10:25:56 +0000 (GMT)
Hugh Dickins <hugh@veritas.com> wrote:
> > Sigh, it's very complicated. An idea which comes to me now is disallowing
> > uncharge while force_empty is running and use Takahashi-san's method.
> > It will be not so complicated.
> 
> Really?  I'd expect disallowing something to add to the complication.
> I agree it's all rather subtle, but I'd rather it worked naturally
> with itself than we bolt on extra prohibitions.  (I was frustrated
> by the EBUSY failure of force_empty, so doing my testing with that
> commented out, forcing empty with concurrent activity.)
> 
> And I'm not clear whether you're saying I'm wrong to move down that
> css_put, for complicated reasons that you've not explained; or that
> I'm right, and this is another example of how easy it is to get it
> slightly wrong.  Please clarify!
> 
Sorry, All messy things "I added" by force_empty is complicated ;(
(sorry for noise)

And you're right that css_put() if remove_list is succeeded is good idea, 
I think.


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
