Subject: Re: [-mm PATCH 8/9] Memory controller add switch to control what
 type of pages to limit (v4)
In-Reply-To: Your message of "Mon, 13 Aug 2007 11:08:58 +0530"
	<46BFEE72.9080209@linux.vnet.ibm.com>
References: <46BFEE72.9080209@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Message-Id: <20070813060427.0334E1BF9D8@siro.lan>
Date: Mon, 13 Aug 2007 15:04:26 +0900 (JST)
From: yamamoto@valinux.co.jp (YAMAMOTO Takashi)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: akpm@linux-foundation.org, a.p.zijlstra@chello.nl, dhaval@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ebiederm@xmission.com, containers@lists.osdl.org, menage@google.com, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

> YAMAMOTO Takashi wrote:
> >> Choose if we want cached pages to be accounted or not. By default both
> >> are accounted for. A new set of tunables are added.
> >>
> >> echo -n 1 > mem_control_type
> >>
> >> switches the accounting to account for only mapped pages
> >>
> >> echo -n 2 > mem_control_type
> >>
> >> switches the behaviour back
> > 
> > MEM_CONTAINER_TYPE_ALL is 3, not 2.
> > 
> 
> Thanks, I'll fix the comment on the top.
> 
> > YAMAMOTO Takashi
> > 
> >> +enum {
> >> +	MEM_CONTAINER_TYPE_UNSPEC = 0,
> >> +	MEM_CONTAINER_TYPE_MAPPED,
> >> +	MEM_CONTAINER_TYPE_CACHED,

what's MEM_CONTAINER_TYPE_CACHED, btw?
it seems that nothing distinguishes it from MEM_CONTAINER_TYPE_MAPPED.

YAMAMOTO Takashi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
