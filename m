Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id CB03B6B0044
	for <linux-mm@kvack.org>; Thu,  5 Nov 2009 12:56:41 -0500 (EST)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 9C76882C83D
	for <linux-mm@kvack.org>; Thu,  5 Nov 2009 13:03:24 -0500 (EST)
Received: from smtp.ultrahosting.com ([74.213.175.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id OBSjj5xKkJ2T for <linux-mm@kvack.org>;
	Thu,  5 Nov 2009 13:03:20 -0500 (EST)
Received: from V090114053VZO-1 (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id D595B7003D9
	for <linux-mm@kvack.org>; Thu,  5 Nov 2009 10:18:35 -0500 (EST)
Date: Thu, 5 Nov 2009 10:10:56 -0500 (EST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [MM] Make mm counters per cpu instead of atomic
In-Reply-To: <20091105101650.45204e4e.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.1.10.0911051008260.25718@V090114053VZO-1>
References: <alpine.DEB.1.10.0911041409020.7409@V090114053VZO-1> <20091105101650.45204e4e.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Tejun Heo <tj@kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 5 Nov 2009, KAMEZAWA Hiroyuki wrote:

> Hmm, I don't fully understand _new_ percpu but...
> In logical (even if not realistic), x86-32 supports up to 512 ? cpus in Kconfig.
> BIGSMP.

x86-32 only supports 32 processors. Plus per cpu areas are only allocated
for the possible processors.

> Then, if 65536 process runs, this consumes
>
> 65536(nr_proc) * 8 (size) * 512(cpus) = 256MBytes.

With 32 possible cpus this results in 16m of per cpu space use.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
