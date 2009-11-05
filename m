Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 2EBC46B0044
	for <linux-mm@kvack.org>; Thu,  5 Nov 2009 13:11:12 -0500 (EST)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id F330382C3E9
	for <linux-mm@kvack.org>; Thu,  5 Nov 2009 13:17:51 -0500 (EST)
Received: from smtp.ultrahosting.com ([74.213.175.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id n87+pwhawHkb for <linux-mm@kvack.org>;
	Thu,  5 Nov 2009 13:17:47 -0500 (EST)
Received: from V090114053VZO-1 (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 1CFDE70039F
	for <linux-mm@kvack.org>; Thu,  5 Nov 2009 10:12:40 -0500 (EST)
Date: Thu, 5 Nov 2009 10:04:55 -0500 (EST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [MM] Make mm counters per cpu instead of atomic
In-Reply-To: <20091104234923.GA25306@redhat.com>
Message-ID: <alpine.DEB.1.10.0911051004360.25718@V090114053VZO-1>
References: <alpine.DEB.1.10.0911041409020.7409@V090114053VZO-1> <20091104234923.GA25306@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Dave Jones <davej@redhat.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Tejun Heo <tj@kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 4 Nov 2009, Dave Jones wrote:

> On Wed, Nov 04, 2009 at 02:14:41PM -0500, Christoph Lameter wrote:
>
>  > +		memset(m, sizeof(struct mm_counter), 0);
>
> Args wrong way around.

Right. It works because percpu_alloc zeroes the data anyways.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
