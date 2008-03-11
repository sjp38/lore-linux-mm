Message-ID: <47D645C9.3020201@openvz.org>
Date: Tue, 11 Mar 2008 11:41:45 +0300
From: Pavel Emelyanov <xemul@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] Add the max_usage member on the res_counter
References: <47D15FAF.3000204@openvz.org> <20080308133307.a2e02402.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080308133307.a2e02402.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Paul Menage <menage@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Linux Containers <containers@lists.osdl.org>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Fri, 07 Mar 2008 18:30:55 +0300
> Pavel Emelyanov <xemul@openvz.org> wrote:
> 
>> This is a very usefull feature. E.g. one may set the
>> limit to "unlimited" value and check for the memory
>> requirements of a new container.
>>
> Hm, I like this. Could you add a method to reset this counter ?

OK. Sounds reasonable.

> How about
> 
> 	counter->max_usage = max(counter->usage, counter->max_usage);

No, I prefer explicit checks :)

> Looks very good,
> 
> Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>

OK. I'll push this change the the git at openvz.org then.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
