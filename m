Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id F2D636B0044
	for <linux-mm@kvack.org>; Sat, 24 Mar 2012 01:53:30 -0400 (EDT)
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glkm-linux-mm-2@m.gmane.org>)
	id 1SBJuo-0001Qa-Dk
	for linux-mm@kvack.org; Sat, 24 Mar 2012 06:53:26 +0100
Received: from 125.70.184.203 ([125.70.184.203])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Sat, 24 Mar 2012 06:53:26 +0100
Received: from xiyou.wangcong by 125.70.184.203 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Sat, 24 Mar 2012 06:53:26 +0100
From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] memcg swap: mem_cgroup_move_swap_account never needs
 fixup
Date: Sat, 24 Mar 2012 05:53:15 +0000 (UTC)
Message-ID: <jkjng9$iu2$1@dough.gmane.org>
References: <alpine.LSU.2.00.1203231348510.1940@eggly.anvils>
 <20120323140918.804b3860.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

On Fri, 23 Mar 2012 at 21:09 GMT, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Fri, 23 Mar 2012 13:51:26 -0700 (PDT)
> Hugh Dickins <hughd@google.com> wrote:
>
>> I believe it's now agreed that an 81-column line is better left unsplit.
>
> There's always a way ;)
>
>> +			if (!mem_cgroup_move_swap_account(ent, mc.from, mc.to)) {
>
> The code sometimes uses "mem_cgroup" and sometimes "memcg".  I don't
> think the _, r, o, u and p add any value...
>

It seems that all global function/structs use "mem_cgroup", while local
variables use "memcg", don't know if this is a rule...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
