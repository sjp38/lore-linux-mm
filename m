Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id BC7006B0062
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 12:12:36 -0500 (EST)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 04E0A82C375
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 12:19:25 -0500 (EST)
Received: from smtp.ultrahosting.com ([74.213.175.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id elAUonXDicXD for <linux-mm@kvack.org>;
	Fri,  6 Nov 2009 12:19:24 -0500 (EST)
Received: from V090114053VZO-1 (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id D9FA382C45B
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 12:18:40 -0500 (EST)
Date: Fri, 6 Nov 2009 12:10:45 -0500 (EST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: Subject: [RFC MM] mmap_sem scaling: Use mutex and percpu counter
  instead
In-Reply-To: <28c262360911060741x3f7ab0a2k15be645e287e05ac@mail.gmail.com>
Message-ID: <alpine.DEB.1.10.0911061209520.5187@V090114053VZO-1>
References: <alpine.DEB.1.10.0911051417370.24312@V090114053VZO-1>  <alpine.DEB.1.10.0911051419320.24312@V090114053VZO-1> <28c262360911060741x3f7ab0a2k15be645e287e05ac@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: npiggin@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@elte.hu>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

On Sat, 7 Nov 2009, Minchan Kim wrote:

> How about change from 'mm_readers' to 'is_readers' to improve your
> goal 'scalibility'?

Good idea. Thanks. Next rev will use your suggestion.

Any creative thoughts on what to do about the 1 millisecond wait period?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
