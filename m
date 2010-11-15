Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 4949B8D0017
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 07:46:34 -0500 (EST)
Received: by qyk31 with SMTP id 31so8238qyk.14
        for <linux-mm@kvack.org>; Mon, 15 Nov 2010 04:46:32 -0800 (PST)
From: Ben Gamari <bgamari.foss@gmail.com>
Subject: Re: fadvise DONTNEED implementation (or lack thereof)
In-Reply-To: <20101115162713.BF12.A69D9226@jp.fujitsu.com>
References: <20101115160413.BF0F.A69D9226@jp.fujitsu.com> <AANLkTim0vCJkMoH5P0wCN9J6340rDsscyNBQ+R+_ph8m@mail.gmail.com> <20101115162713.BF12.A69D9226@jp.fujitsu.com>
Date: Mon, 15 Nov 2010 07:46:26 -0500
Message-ID: <87tyjisqjh.fsf@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>
Cc: linux-kernel@vger.kernel.org, rsync@lists.samba.org, linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

On Mon, 15 Nov 2010 16:28:32 +0900 (JST), KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> Who can make rsync like io pattern test suite? a code change is easy. but
> to comfirm justification is more harder work.
> 
I'm afraid I don't have time to work up any code. I would be happy to
try the patch with my backup use-case though. I'll just have to think
of an objective way of measuring the result.

- Ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
