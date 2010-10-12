Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id C38696B00C1
	for <linux-mm@kvack.org>; Tue, 12 Oct 2010 05:20:06 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9C9K5Q2016887
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 12 Oct 2010 18:20:05 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id A1B3B45DE4F
	for <linux-mm@kvack.org>; Tue, 12 Oct 2010 18:20:05 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 6944E45DD70
	for <linux-mm@kvack.org>; Tue, 12 Oct 2010 18:20:05 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 435F81DB8012
	for <linux-mm@kvack.org>; Tue, 12 Oct 2010 18:20:05 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id E35B11DB8013
	for <linux-mm@kvack.org>; Tue, 12 Oct 2010 18:20:04 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: RFC: Implement hwpoison on free for soft offlining
In-Reply-To: <87aamj3k6f.fsf@basil.nowhere.org>
References: <1286402951-1881-1-git-send-email-andi@firstfloor.org> <87aamj3k6f.fsf@basil.nowhere.org>
Message-Id: <20101012181439.ADA9.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 12 Oct 2010 18:20:04 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, fengguang.wu@intel.com, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

> Andi Kleen <andi@firstfloor.org> writes:
> 
> > Here's a somewhat experimental patch to improve soft offlining
> > in hwpoison, but allowing hwpoison on free for not directly
> > freeable page types. It should work for nearly all
> > left over page types that get eventually freed, so this makes
> > soft offlining nearly universal. The only non handleable page
> > types are now pages that never get freed.
> >
> > Drawback: It needs an additional page flag. Cannot set hwpoison
> > directly because that would not be "soft" and cause errors.
> 
> Ping? Any comments on this patch?
> 
> Except for the page flag use I think it's nearly a no brainer. 
> A lot of new soft hwpoison capability for very little additional code.
> 
> Has anyone a problem using up a 64bit page flag for that?

To me, it's no problem if this keep 64bit only. IOW, I only dislike to
add 32bit page flags.

Yeah, memory corruption is very crap and i think your effort has a lot
of worth :)


offtopic, I don't think CONFIG_MEMORY_FAILURE and CONFIG_HWPOISON_ON_FREE
are symmetric nor easy understandable. can you please consider naming change?
(example, CONFIG_HWPOISON/CONFIG_HWPOISON_ON_FREE, 
CONFIG_MEMORY_FAILURE/CONFIG_MEMORY_FAILURE_SOFT_OFFLINE)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
