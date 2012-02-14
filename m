Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 328066B13F0
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 17:06:38 -0500 (EST)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <john.stultz@linaro.org>;
	Tue, 14 Feb 2012 15:06:36 -0700
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 73DDF3E4004A
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 15:06:13 -0700 (MST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q1EM67PP121624
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 15:06:09 -0700
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q1EM6DQx028233
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 15:06:14 -0700
Message-ID: <1329257161.2340.1.camel@work-vm>
Subject: Re: [RFC] [PATCH v5 0/3] fadvise: support POSIX_FADV_NOREUSE
From: John Stultz <john.stultz@linaro.org>
Date: Tue, 14 Feb 2012 14:06:01 -0800
In-Reply-To: <20120214133337.9de7835b.akpm@linux-foundation.org>
References: <1329006098-5454-1-git-send-email-andrea@betterlinux.com>
	 <20120214133337.9de7835b.akpm@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Righi <andrea@betterlinux.com>, Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Shaohua Li <shaohua.li@intel.com>, =?ISO-8859-1?Q?P=E1draig?= Brady <P@draigBrady.com>, Jerry James <jamesjer@betterlinux.com>, Julius Plenz <julius@plenz.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Tue, 2012-02-14 at 13:33 -0800, Andrew Morton wrote:
> On Sun, 12 Feb 2012 01:21:35 +0100
> Andrea Righi <andrea@betterlinux.com> wrote:
> 
> > The new proposal is to implement POSIX_FADV_NOREUSE as a way to perform a real
> > drop-behind policy where applications can mark certain intervals of a file as
> > FADV_NOREUSE before accessing the data.
> 
> I think you and John need to talk to each other, please.  The amount of
> duplication here is extraordinary.

Yea. Clearly there is much we can share. I'm still catching up from a
conference last week, so I've not had a chance to really look at this
yet, but its on my queue for this week.

thanks
-john


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
