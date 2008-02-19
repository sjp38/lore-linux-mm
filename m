From: kamezawa.hiroyu@jp.fujitsu.com
Message-ID: <17878602.1203436460680.kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 20 Feb 2008 00:54:20 +0900 (JST)
Subject: Re: Re: [RFC][PATCH] Clarify mem_cgroup lock handling and avoid races.
In-Reply-To: <Pine.LNX.4.64.0802191449490.6254@blonde.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
References: <Pine.LNX.4.64.0802191449490.6254@blonde.site>
 <20080219215431.1aa9fa8a.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, balbir@linux.vnet.ibm.com, yamamoto@valinux.co.jp, riel@redhat.com
List-ID: <linux-mm.kvack.org>

>How should I proceed now?  I think it's best if I press ahead with
>my patchset, to get that out on to the list; and only then come
>back to look at yours, while you can be looking at mine.  Then
>we take the best out of both and push that forward - this does
>need to be fixed for 2.6.25.
>
I'm very glad to hear that you have been working on this already.

I think it's better to test your one at first because it sounds
you've already seem the BUG much more than I've seen and
I think my patch will need more work to be simple.

Could you post your one ? I'll try it on my box.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
