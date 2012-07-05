From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch] mm/policy: use int instead of unsigned for nid
Date: Thu, 5 Jul 2012 13:37:31 +0000 (UTC)
Message-ID: <jt45ar$lq0$3@dough.gmane.org>
References: <1341370901-14187-1-git-send-email-amwang@redhat.com>
 <alpine.DEB.2.00.1207032342120.32556@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
List-Id: linux-mm.kvack.org

On Wed, 04 Jul 2012 at 06:43 GMT, David Rientjes <rientjes@google.com> wrote:
> On Wed, 4 Jul 2012, Cong Wang wrote:
>
>> From: WANG Cong <xiyou.wangcong@gmail.com>
>> 
>> 'nid' should be 'int', not 'unsigned'.
>> 
>
> unsigned is already of type int, so you're saying these occurrences should 
> become signed, but that's not true since they never return NUMA_NO_NODE.  
> They are all safe returning unsigned.
>

Yeah, I knew, just thought using 'int' is consistent, this is a
trivial patch, not a bugfix.

> And alloc_page_interleave() doesn't exist anymore since the sched/numa 
> bits were merged into sched/core, so nobody could apply this patch anyway.

Ah, I made this patch against linus tree...
