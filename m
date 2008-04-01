Subject: Re: [RFC][-mm] Add an owner to the mm_struct (v3)
In-Reply-To: Your message of "Mon, 31 Mar 2008 23:06:12 -0700"
	<6599ad830803312306l59fabaa0o2f62feb0d59b2ce3@mail.gmail.com>
References: <6599ad830803312306l59fabaa0o2f62feb0d59b2ce3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Message-Id: <20080401062427.A3E785A05@siro.lan>
Date: Tue,  1 Apr 2008 15:24:27 +0900 (JST)
From: yamamoto@valinux.co.jp (YAMAMOTO Takashi)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: menage@google.com
Cc: balbir@linux.vnet.ibm.com, xemul@openvz.org, hugh@veritas.com, skumar@linux.vnet.ibm.com, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, rientjes@google.com, akpm@linux-foundation.org, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

> On Mon, Mar 31, 2008 at 11:03 PM, YAMAMOTO Takashi
> <yamamoto@valinux.co.jp> wrote:
> >
> >  changing mm->owner without notifying controllers makes it difficult to use.
> >  can you provide a notification mechanism?
> >
> 
> Yes, I think that call will need to be in the task_lock() critical
> section in which we update mm->owner.
> 
> Right now I think the only user that needs to be notified at that
> point is Balbir's virtual address limits controller.
> 
> Paul

i have some code for which i might want to use mm->owner.
it does somewhat complicated things like acquiring mm_sem and
traversing ptes in its ->attach hook.  (if you want to read the code, search
"Subject: [RFC][PATCH] another swap controller for cgroup" in ML archive.)

probably i don't need to use mm->owner, but it's better if mm->owner can
handle more cases anyway.

YAMAMOTO Takashi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
