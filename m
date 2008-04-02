From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][-mm] Add an owner to the mm_struct (v4)
Date: Wed, 02 Apr 2008 12:10:43 +0530
Message-ID: <47F32A6B.1070709@linux.vnet.ibm.com>
References: <20080401124312.23664.64616.sendpatchset@localhost.localdomain> <20080402093157.e445acfb.kamezawa.hiroyu@jp.fujitsu.com> <47F2FCAE.7070401@linux.vnet.ibm.com> <20080402135357.04c3e79f.kamezawa.hiroyu@jp.fujitsu.com>
Reply-To: balbir@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760241AbYDBGps@vger.kernel.org>
In-Reply-To: <20080402135357.04c3e79f.kamezawa.hiroyu@jp.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Paul Menage <menage@google.com>, Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
List-Id: linux-mm.kvack.org

KAMEZAWA Hiroyuki wrote:
> On Wed, 02 Apr 2008 08:55:34 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
>>>> +	/*
>>>> +	 * Search through everything else. We should not get
>>>> +	 * here often
>>>> +	 */
>>>> +	do_each_thread(g, c) {
>>>> +		if (c->mm == mm)
>>>> +			goto assign_new_owner;
>>>> +	} while_each_thread(g, c);
>>> Doing above in synchronized manner seems too heavy.
>>> When this happen ? or Can this be done in lazy "on-demand" manner ?
>>>
>> Do you mean under task_lock()?
>>
> No, scanning itself. 
> How rarely this scan happens under a server which has 10000- threads ?
> 

This routine will be called every time a thread exits, but will quickly exit
after checking mm_need_new_owner()


-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
