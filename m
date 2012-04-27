Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id F0FB96B004A
	for <linux-mm@kvack.org>; Thu, 26 Apr 2012 23:01:55 -0400 (EDT)
Date: Thu, 26 Apr 2012 22:02:24 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: 3.4-rc4 oom killer out of control.
Message-ID: <20120427020224.GA22927@redhat.com>
References: <20120426193551.GA24968@redhat.com>
 <alpine.DEB.2.00.1204261437470.28376@chino.kir.corp.google.com>
 <20120426215257.GA12908@redhat.com>
 <alpine.DEB.2.00.1204261517100.28376@chino.kir.corp.google.com>
 <20120426224419.GA13598@redhat.com>
 <20120427005448.GD23877@home.goodmis.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120427005448.GD23877@home.goodmis.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Linux Kernel <linux-kernel@vger.kernel.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Thu, Apr 26, 2012 at 08:54:48PM -0400, Steven Rostedt wrote:
 
 > >  > full_scans is just a counter of how many times it has scanned mergable 
 > >  > memory so it should be increasing constantly.  Whether pages_to_scan == 
 > >  > 1250 and sleep_millisecs == 20 is good for your system is unknown.  You 
 > >  > may want to try disabling ksm entirely (echo 0 > /sys/kernel/mm/ksm/run) 
 > >  > to see if it significantly increases responsiveness for your workload.
 > > 
 > 
 > You didn't happen to see any RCU CPU stalls, did you?

nothing got reported in dmesg..

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
