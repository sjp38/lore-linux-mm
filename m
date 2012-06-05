Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 7BF636B0062
	for <linux-mm@kvack.org>; Tue,  5 Jun 2012 13:45:00 -0400 (EDT)
Date: Tue, 5 Jun 2012 13:44:54 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: oomkillers gone wild.
Message-ID: <20120605174454.GA23867@redhat.com>
References: <20120604152710.GA1710@redhat.com>
 <alpine.DEB.2.00.1206041629500.7769@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1206041629500.7769@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Mon, Jun 04, 2012 at 04:30:57PM -0700, David Rientjes wrote:
 > On Mon, 4 Jun 2012, Dave Jones wrote:
 > 
 > > we picked this..
 > > 
 > > [21623.066911] [  588]     0   588    22206        1   2       0             0 dhclient
 > > 
 > > over say..
 > > 
 > > [21623.116597] [ 7092]  1000  7092  1051124    31660   3       0             0 trinity-child3
 > > 
 > > What went wrong here ?
 > > 
 > > And why does that score look so.. weird.
 > > 
 > 
 > It sounds like it's because pid 588 has uid=0 and the adjustment for root 
 > processes is causing an overflow.  I assume this fixes it?

Still doesn't seem right..

eg..

[42309.542776] [ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name
..
[42309.553933] [  500]    81   500     5435        1   4     -13          -900 dbus-daemon
..
[42309.597531] [ 9054]  1000  9054   528677    14540   3       0             0 trinity-child3
..

[42309.643057] Out of memory: Kill process 500 (dbus-daemon) score 511952 or sacrifice child
[42309.643620] Killed process 500 (dbus-daemon) total-vm:21740kB, anon-rss:0kB, file-rss:4kB

and a slew of similar 'wrong process' death spiral kills follows..


	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
