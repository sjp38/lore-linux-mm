Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 1278F6B00EE
	for <linux-mm@kvack.org>; Tue, 26 Jul 2011 19:17:20 -0400 (EDT)
Date: Tue, 26 Jul 2011 16:17:14 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -mmotm] fault-injection: add ability to export
 fault_attr in arbitrary directory
Message-Id: <20110726161714.9b1b5084.akpm@linux-foundation.org>
In-Reply-To: <1311721597-2606-1-git-send-email-akinobu.mita@gmail.com>
References: <1311721597-2606-1-git-send-email-akinobu.mita@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Akinobu Mita <akinobu.mita@gmail.com>
Cc: linux-kernel@vger.kernel.org, Per Forlin <per.forlin@linaro.org>, Jens Axboe <axboe@kernel.dk>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org

On Wed, 27 Jul 2011 08:06:37 +0900
Akinobu Mita <akinobu.mita@gmail.com> wrote:

> init_fault_attr_dentries() is used to export fault_attr via debugfs.  But
> it can only export it in debugfs root directory.
> 
> Per Forlin is working on mmc_fail_request which adds support to inject
> data errors after a completed host transfer in MMC subsystem.
> 
> The fault_attr for mmc_fail_request should be defined per mmc host and
> export it in debugfs directory per mmc host like
> /sys/kernel/debug/mmc0/mmc_fail_request.
> 
> init_fault_attr_dentries() doesn't help for mmc_fail_request.  So this
> introduces debugfs_create_fault_attr() which is able to create a directory
> in the arbitrary directory and replace init_fault_attr_dentries().

The name is wrong.  "debugfs_create_fault_attr" refers to some function
exported by the debugfs code.  But this function is exported by the
fault injection code.

I edited the patch and renamed it to fault_create_debugfs_attr, which
may not make a ton of sense - please let me know if there's something
more appropriate.

I suggest that all symbols exported by this system should start with
"fault_".  ("fault_injection_" would be more appropriate, but it's
rather lengthy).  Please take a look through the code, see if there's
anything else we should clean up.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
