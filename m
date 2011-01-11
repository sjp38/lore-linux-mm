Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id C7C9F6B00E7
	for <linux-mm@kvack.org>; Tue, 11 Jan 2011 03:00:28 -0500 (EST)
Date: Tue, 11 Jan 2011 03:00:26 -0500 (EST)
From: CAI Qian <caiqian@redhat.com>
Message-ID: <1197944404.42526.1294732826847.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
In-Reply-To: <704975885.41077.1294719050536.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
Subject: Re: bnx2 card cannot be detected (WAS Re: mmotm 2011-01-06-15-41
 uploaded)
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-next <linux-next@vger.kernel.org>
List-ID: <linux-mm.kvack.org>


> This was introduced again by this big patch,
> linux-next.patch
> 
> GIT 47ec85165ad275a2ca62c4aca4bf029e9ffd6af0
> git+ssh://master.kernel.org/pub/scmm
> /linux/kernel/git/sfr/linux-next.git
Tested in the linux-next tree, and the problem went away with 2.6.37-next-20110111.

CAI Qian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
