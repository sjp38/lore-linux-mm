Received: by el-out-1112.google.com with SMTP id o28so23761ele.26
        for <linux-mm@kvack.org>; Thu, 22 May 2008 05:32:37 -0700 (PDT)
Message-ID: <2f11576a0805220532l668ca59emd37afb60f50b703@mail.gmail.com>
Date: Thu, 22 May 2008 21:32:36 +0900
From: "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 4/4] swapcgroup: modify vm_swap_full for cgroup
In-Reply-To: <4835656D.4020706@mxp.nes.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <48350F15.9070007@mxp.nes.nec.co.jp>
	 <48351120.6000800@mxp.nes.nec.co.jp>
	 <20080522165322.F516.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <4835656D.4020706@mxp.nes.nec.co.jp>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Linux Containers <containers@lists.osdl.org>, Linux MM <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Hugh Dickins <hugh@veritas.com>, "IKEDA, Munehiro" <m-ikeda@ds.jp.nec.com>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

>> I'd prefer #ifdef rather than #ifndef.
>>
>> so...
>>
>> #ifdef CONFIG_CGROUP_SWAP_RES_CTLR
>>   your definition
>> #else
>>   original definition
>> #endif
>>
> OK.
> I'll change it.

Thanks.


>> and vm_swap_full() isn't page granularity operation.
>> this is memory(or swap) cgroup operation.
>>
>> this argument is slightly odd.
>>
> But what callers of vm_swap_full() know is page,
> not mem_cgroup.
> I don't want to add to callers something like:
>
>  pc = get_page_cgroup(page);
>  mem = pc->mem_cgroup;
>  vm_swap_full(mem);

perhaps, I don't understand your intention exactly.
Why can't you make wrapper function?

e.g.
    vm_swap_full(page_to_memcg(page))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
