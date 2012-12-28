Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 8210E6B005A
	for <linux-mm@kvack.org>; Thu, 27 Dec 2012 19:26:07 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id AF75D3EE0C0
	for <linux-mm@kvack.org>; Fri, 28 Dec 2012 09:26:05 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8D86D45DEBE
	for <linux-mm@kvack.org>; Fri, 28 Dec 2012 09:26:05 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7578945DEB7
	for <linux-mm@kvack.org>; Fri, 28 Dec 2012 09:26:05 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 665701DB8041
	for <linux-mm@kvack.org>; Fri, 28 Dec 2012 09:26:05 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1BB811DB803E
	for <linux-mm@kvack.org>; Fri, 28 Dec 2012 09:26:05 +0900 (JST)
Message-ID: <50DCE6D5.7000901@jp.fujitsu.com>
Date: Fri, 28 Dec 2012 09:24:53 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC v4 0/3] Support volatile for anonymous range
References: <1355813274-571-1-git-send-email-minchan@kernel.org> <50DA62CE.30604@jp.fujitsu.com> <20121226034600.GB2453@blaptop>
In-Reply-To: <20121226034600.GB2453@blaptop>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, Arun Sharma <asharma@fb.com>, sanjay@google.com, Paul Turner <pjt@google.com>, David Rientjes <rientjes@google.com>, John Stultz <john.stultz@linaro.org>, Christoph Lameter <cl@linux.com>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>

(2012/12/26 12:46), Minchan Kim wrote:
> Hi Kame,
>
> What are you doing these holiday season? :)
> I can't believe you sit down in front of computer.
>
Honestly, my holiday starts tomorrow ;) (but until 1/5 in the next year.)

>>
>> Hm, by the way, the user need to attach pages to the process by causing page-fault
>> (as you do by memset()) before calling mvolatile() ?
>
> For effectiveness, Yes.
>

Isn't it better to make page-fault by get_user_pages() in mvolatile() ?
Calling page fault in userland seems just to increase burden of apps.

>>
>> I think your approach is interesting, anyway.
>
> Thanks for your interest, Kame.
>
> a??a??a? 3/4 a??a?|a??a??a??a??a??.
>

A happy new year.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
