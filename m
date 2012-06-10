Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id C20E66B006C
	for <linux-mm@kvack.org>; Sun, 10 Jun 2012 16:11:03 -0400 (EDT)
Date: Sun, 10 Jun 2012 16:10:56 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: oomkillers gone wild.
Message-ID: <20120610201055.GA27662@redhat.com>
References: <20120604152710.GA1710@redhat.com>
 <alpine.DEB.2.00.1206041629500.7769@chino.kir.corp.google.com>
 <20120605174454.GA23867@redhat.com>
 <alpine.DEB.2.00.1206081313000.19054@chino.kir.corp.google.com>
 <20120608210330.GA21010@redhat.com>
 <alpine.DEB.2.00.1206091920140.7832@chino.kir.corp.google.com>
 <4FD412CB.9060809@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FD412CB.9060809@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: David Rientjes <rientjes@google.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Sat, Jun 09, 2012 at 11:21:47PM -0400, KOSAKI Motohiro wrote:
 > (6/9/12 10:21 PM), David Rientjes wrote:
 > > On Fri, 8 Jun 2012, Dave Jones wrote:
 > >
 > >>   >  On a system not under oom conditions, i.e. before you start trinity, can
 > >>   >  you send the output of
 > >>   >
 > >>   >  	cat /proc/$(pidof dbus-daemon)/oom_score{_adj,}
 > >>   >  	grep RSS /proc/$(pidof dbus-daemon)/status
 > >>
 > >> # cat /proc/$(pidof dbus-daemon)/oom_score{_adj,}
 > >> -900
 > >> 7441500919753
 > >> # grep RSS /proc/$(pidof dbus-daemon)/status
 > >> VmRSS:	    1660 kB
 > >
 > > I'm suspecting you don't have my patch that changes the type of the
 > > automatic variable in oom_badness() to signed.  Could you retry this with
 > > that patch or pull 3.5-rc2 which already includes it?

that was with the unsigned long -> long patch.

 > Yes. Dave (Jones), As far as parsed your log, you are using x86_64, right?

yes.

 > As far as my testing, current linus tree works fine at least normal case.
 > please respin.

To double check, here it is in rc2 (which has that patch)..

$ uname -r
3.5.0-rc2+
$ cat /proc/$(pidof dbus-daemon)/oom_score{_adj,}
-900
7441500919753
$ grep RSS /proc/$(pidof dbus-daemon)/status
VmRSS:	    1604 kB

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
