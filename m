Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 69F766B01B1
	for <linux-mm@kvack.org>; Thu, 20 May 2010 21:12:06 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o4L1C3JQ024075
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 21 May 2010 10:12:03 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 827DD45DE4E
	for <linux-mm@kvack.org>; Fri, 21 May 2010 10:12:03 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6661E45DE4D
	for <linux-mm@kvack.org>; Fri, 21 May 2010 10:12:03 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 51625E08001
	for <linux-mm@kvack.org>; Fri, 21 May 2010 10:12:03 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0C1B1E08005
	for <linux-mm@kvack.org>; Fri, 21 May 2010 10:12:00 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: RFC: dirty_ratio back to 40%
In-Reply-To: <4BF5D875.3030900@acm.org>
References: <20100521083408.1E36.A69D9226@jp.fujitsu.com> <4BF5D875.3030900@acm.org>
Message-Id: <20100521100943.1E4D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 21 May 2010 10:11:59 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Zan Lynx <zlynx@acm.org>
Cc: kosaki.motohiro@jp.fujitsu.com, lwoodman@redhat.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Nick Piggin <npiggin@suse.de>, Jan Kara <jack@suse.cz>
List-ID: <linux-mm.kvack.org>

> > So, I'd prefer to restore the default rather than both Redhat and SUSE apply exactly
> > same distro specific patch. because we can easily imazine other users will face the same
> > issue in the future.
> 
> On desktop systems the low dirty limits help maintain interactive feel. 
> Users expect applications that are saving data to be slow. They do not 
> like it when every application in the system randomly comes to a halt 
> because of one program stuffing data up to the dirty limit.

really?
Do you mean our per-task dirty limit wouldn't works?

If so, I think we need fix it. IOW sane per-task dirty limitation seems independent issue 
from per-system dirty limit.


> The cause and effect for the system slowdown is clear when the dirty 
> limit is low. "I saved data and now the system is slow until it is 
> done." When the dirty page ratio is very high, the cause and effect is 
> disconnected. "I was just web surfing and the system came to a halt."
> 
> I think we should expect server admins to do more tuning than desktop 
> users, so the default limits should stay low in my opinion.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
