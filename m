Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id ED9F46B0089
	for <linux-mm@kvack.org>; Fri, 24 Dec 2010 22:00:26 -0500 (EST)
Date: Sat, 25 Dec 2010 11:00:19 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: dirty throttling v5 for 2.6.37-rc7+
Message-ID: <20101225030019.GA25383@localhost>
References: <20101224170418.GA3405@gamma.logic.tuwien.ac.at>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101224170418.GA3405@gamma.logic.tuwien.ac.at>
Sender: owner-linux-mm@kvack.org
To: Norbert Preining <preining@logic.at>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi Norbert,

Merry Christmas! :)

On Sat, Dec 25, 2010 at 01:04:18AM +0800, Norbert Preining wrote:
> Hi Wu, hi everyone,
> 
> (pleae Cc)
> 
> is there any chance to get a git pull-able repository of the
> 	IO-less dirty throttling v4
> patches (git://git.kernel.org/pub/scm/linux/kernel/git/wfg/writeback.git dirty-throttling-v4) for usage with current git kernel? There are several
> rejects if I try to merge them into the current linux-2.6 head.

I just created branch "dirty-throttling-v5" based on today's linux-2.6 head.

git://git.kernel.org/pub/scm/linux/kernel/git/wfg/writeback.git  dirty-throttling-v5

The test scripts are also updated at

http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/tests/ 

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
