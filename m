Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 17D606B0088
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 19:26:46 -0500 (EST)
Received: by iacb35 with SMTP id b35so2148965iac.14
        for <linux-mm@kvack.org>; Thu, 05 Jan 2012 16:26:45 -0800 (PST)
Message-ID: <4F063FC0.8000907@gmail.com>
Date: Thu, 05 Jan 2012 19:26:40 -0500
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3.2.0-rc1 0/3] Used Memory Meter pseudo-device and related
 changes in MM
References: <cover.1325696593.git.leonid.moiseichuk@nokia.com> <20120104195612.GB19181@suse.de> <84FF21A720B0874AA94B46D76DB98269045542B5@008-AM1MPN1-003.mgdnok.nokia.com>
In-Reply-To: <84FF21A720B0874AA94B46D76DB98269045542B5@008-AM1MPN1-003.mgdnok.nokia.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: leonid.moiseichuk@nokia.com
Cc: kosaki.motohiro@gmail.com, gregkh@suse.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cesarb@cesarb.net, kamezawa.hiroyu@jp.fujitsu.com, emunson@mgebm.net, penberg@kernel.org, aarcange@redhat.com, riel@redhat.com, mel@csn.ul.ie, rientjes@google.com, dima@android.com, rebecca@android.com, san@google.com, akpm@linux-foundation.org, vesa.jaaskelainen@nokia.com

> Android OOM (AOOM) is a different thing. Briefly Android OOM is a safety belt,
>but I try to introduce look-ahead radar to stop before hitting wall.

You explained why we shouldn't merge neither you nor android notification patches.
Many embedded developers tried to merge their own patch and claimed "Hey! my patch
is completely different from another one". That said, their patches can't be used
each other use case, just for them.

Systemwide global notification itself is not bad idea. But we definitely choose
just one implementation. thus, you need to get agree with other embedded people.

Again, lowmemorykiller.c should be dropped too.


>  UsedMemory = (MemTotal - MemFree - Buffers - Cached - SwapCached) +
>                                               (SwapTotal - SwapFree)

If you spent a few time to read past discuttion, you should have understand your fomula
is broken and unacceptable. Think, mlocked (or pinning by other way) cache can't be
discarded. And, When system is under swap thrashing, userland notification is
useless. I don't think you tested w/ swap environment heavily.

While you are getting stuck to make nokia specific feature, I'm recommending you
maintain your local patch yourself.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
