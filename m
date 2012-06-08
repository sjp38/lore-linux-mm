Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id B34F16B0062
	for <linux-mm@kvack.org>; Fri,  8 Jun 2012 17:03:35 -0400 (EDT)
Date: Fri, 8 Jun 2012 17:03:30 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: oomkillers gone wild.
Message-ID: <20120608210330.GA21010@redhat.com>
References: <20120604152710.GA1710@redhat.com>
 <alpine.DEB.2.00.1206041629500.7769@chino.kir.corp.google.com>
 <20120605174454.GA23867@redhat.com>
 <alpine.DEB.2.00.1206081313000.19054@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1206081313000.19054@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Fri, Jun 08, 2012 at 01:15:50PM -0700, David Rientjes wrote:
 > On Tue, 5 Jun 2012, Dave Jones wrote:
 > 
 > > Still doesn't seem right..
 > > 
 > > eg..
 > > 
 > > [42309.542776] [ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name
 > > ..
 > > [42309.553933] [  500]    81   500     5435        1   4     -13          -900 dbus-daemon
 > > ..
 > > [42309.597531] [ 9054]  1000  9054   528677    14540   3       0             0 trinity-child3
 > > ..
 > > 
 > > [42309.643057] Out of memory: Kill process 500 (dbus-daemon) score 511952 or sacrifice child
 > > [42309.643620] Killed process 500 (dbus-daemon) total-vm:21740kB, anon-rss:0kB, file-rss:4kB
 > > 
 > > and a slew of similar 'wrong process' death spiral kills follows..
 > > 
 > 
 > On a system not under oom conditions, i.e. before you start trinity, can 
 > you send the output of
 > 
 > 	cat /proc/$(pidof dbus-daemon)/oom_score{_adj,}
 > 	grep RSS /proc/$(pidof dbus-daemon)/status

# cat /proc/$(pidof dbus-daemon)/oom_score{_adj,}
-900
7441500919753
# grep RSS /proc/$(pidof dbus-daemon)/status
VmRSS:	    1660 kB



	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
