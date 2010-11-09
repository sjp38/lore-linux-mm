Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 4579D6B00B6
	for <linux-mm@kvack.org>; Mon,  8 Nov 2010 21:26:32 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oA92QTOT000430
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 9 Nov 2010 11:26:30 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id C69B045DE51
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 11:26:29 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 4A72F45DE4C
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 11:26:29 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 2F8D21DB8016
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 11:26:29 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id D22181DB8012
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 11:26:25 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [resend][PATCH 2/4] Revert "oom: deprecate oom_adj tunable"
In-Reply-To: <alpine.DEB.2.00.1011011232120.6822@chino.kir.corp.google.com>
References: <20101101030353.607A.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1011011232120.6822@chino.kir.corp.google.com>
Message-Id: <20101109105801.BC30.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  9 Nov 2010 11:26:25 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> On Mon, 1 Nov 2010, KOSAKI Motohiro wrote:
> 
> > > The new tunable added in 2.6.36, /proc/pid/oom_score_adj, is necessary for 
> > > the units that the badness score now uses.  We need a tunable with a much 
> > 
> > Who we?
> > 
> 
> Linux users who care about prioritizing tasks for oom kill with a tunable 
> that (1) has a unit, (2) has a higher resolution, and (3) is linear and 
> not exponential.  

No. Majority user don't care. You only talk about your case. Don't ignore
end user.


> Memcg doesn't solve this issue without incurring a 1% 
> memory cost.

Look at a real.
All major distributions has already turn on memcg. End user don't need
to pay additional cost.



> 
> > > higher resolution than the oom_adj scale from -16 to +15, and one that 
> > > scales linearly as opposed to exponentially.  Since that tunable is much 
> > > more powerful than the oom_adj implementation, which never made any real 
> > 
> > The reason that you ware NAKed was not to introduce new powerful feature.
> > It was caused to break old and used feature from applications.
> > 
> 
> No, it doesn't, and you completely and utterly failed to show a single 
> usecase that broke as a result of this because nobody can currently use 
> oom_adj for anything other than polarization.  Thus, there's no backwards 
> compatibility issue.

No. I showed. 
1) Google code search showed some application are using this feature.
	http://www.google.com/codesearch?as_q=oom_adj&btnG=Search+Code&hl=ja&as_package=&as_lang=&as_filename=&as_class=&as_function=&as_license=&as_case=

2) Not body use oom_adj other than polarization even though there are a few.
   example, kde are using.
	http://www.google.com/codesearch/p?hl=ja#MPJuLvSvNYM/pub/kde/unstable/snapshots/kdelibs.tar.bz2%7CWClmGVN5niU/kdelibs-1164923/kinit/start_kdeinit.c&q=oom_adj%20kde%205

When you are talking polarization issue, you blind a real. Don't talk your dream.

3) udev are using this feature. It's one of major linux component and you broke.

http://www.google.com/codesearch/p?hl=ja#KVTjzuVpblQ/pub/linux/utils/kernel/hotplug/udev-072.tar.bz2%7CwUSE-Ay3lLI/udev-072/udevd.c&q=oom_adj

You don't have to break our userland. you can't rewrite or deprecate 
old one. It's used! You can only add orthogonal new knob.


> > > sense for defining oom killing priority for any purpose other than 
> > > polarization, the old tunable is deprecated for two years.
> > 
> > You haven't tested your patch at all. Distro's initram script are using
> > oom_adj interface and latest kernel show pointless warnings 
> > "/proc/xx/oom_adj is deprecated, please use /proc/xx/oom_score_adj instead."
> > at _every_ boot time.
> > 
> 
> Yes, I've tested it, and it deprecates the tunable as expected.  A single 
> warning message serves the purpose well: let users know one time without 
> being overly verbose that the tunable is deprecated and give them 
> sufficient time (2 years) to start using the new tunable.  That's how 
> deprecation is done.

no sense.

Why do their application need to rewrite for *YOU*? Okey, you will got
benefit from your new knob. But NOBDOY use the new one. and People need
to rewrite their application even though no benefit. 

Don't do selfish userland breakage!



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
