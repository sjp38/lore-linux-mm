Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 53E6E6B0092
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 13:43:15 -0500 (EST)
Message-ID: <4F3D4E34.9060105@fb.com>
Date: Thu, 16 Feb 2012 10:43:00 -0800
From: Arun Sharma <asharma@fb.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 3/3] fadvise: implement POSIX_FADV_NOREUSE
References: <1329006098-5454-1-git-send-email-andrea@betterlinux.com> <1329006098-5454-4-git-send-email-andrea@betterlinux.com> <20120215233537.GA20724@dev3310.snc6.facebook.com> <20120215234724.GA21685@thinkpad> <4F3C467B.1@fb.com> <20120216005608.GC21685@thinkpad> <4F3C6594.3030709@fb.com> <20120216103944.GA1440@thinkpad>
In-Reply-To: <20120216103944.GA1440@thinkpad>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Righi <andrea@betterlinux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Shaohua Li <shaohua.li@intel.com>, =?ISO-8859-1?Q?P=E1draig_Brady?= <P@draigBrady.com>, John Stultz <john.stultz@linaro.org>, Jerry James <jamesjer@betterlinux.com>, Julius Plenz <julius@plenz.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On 2/16/12 2:39 AM, Andrea Righi wrote:

> Arun, thank you very much for your review and testing. Probably we'll
> move to a different, memcg-based solution, so I don't think I'll post
> another version of this patch set as is. In case, I'll apply one of
> the workarounds for the rb_root attribute.

I'm not sure if the proposed memory.file.limit_in_bytes is the right 
interface. Two problems:

* The user is now required to figure out what is the right amount of 
page cache for the app (may change over time)

* If the app touches two sets of files, one with streaming access and 
the other which benefits from page cache (eg: a mapper task in a map 
reduce), memcg doesn't allow the user to specify the access pattern per-fd.

  -Arun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
