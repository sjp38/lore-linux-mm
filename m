Received: by an-out-0708.google.com with SMTP id d17so87244and.105
        for <linux-mm@kvack.org>; Fri, 27 Jun 2008 00:57:57 -0700 (PDT)
Message-ID: <28c262360806270057w2b2d3e56ob4dde9aacf42327b@mail.gmail.com>
Date: Fri, 27 Jun 2008 16:57:56 +0900
From: "MinChan Kim" <minchan.kim@gmail.com>
Subject: Re: [-mm][PATCH 8/10] fix shmem page migration incorrectness on memcgroup
In-Reply-To: <20080627142950.7A83.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080625190750.D864.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <28c262360806262208i6791d67at446f7323ded16206@mail.gmail.com>
	 <20080627142950.7A83.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Fri, Jun 27, 2008 at 2:41 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> > mem_cgroup_uncharge() against old page is done after radix-tree-replacement.
>> > And there were special handling to ingore swap-cache page. But, shmem can
>> > be swap-cache and file-cache at the same time. Chekcing PageSwapCache() is
>> > not correct here. Check PageAnon() instead.
>>
>> When/How shmem can be both swap-cache and file-cache ?
>> I can't understand that situation.
>
> Hi
>
> see,
>
> shmem_writepage()
>   -> add_to_swap_cache()
>      -> SetPageSwapCache()
>
>
> BTW: his file-cache mean !Anon, not mean !SwapBacked.

Hi KOSAKI-san.
Thanks for explaining.

In the migrate_page_move_mapping, the page was already locked in unmap_and_move.
Also, we have a lock for that page for calling shmem_writepage.

So I think race problem between shmem_writepage and
migrate_page_move_mapping don't occur.
But I am not sure I am right.

If I am wrong, could you tell me when race problem happen ? :)


>
>



-- 
Kinds regards,
MinChan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
