Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 546976B0044
	for <linux-mm@kvack.org>; Mon,  2 Apr 2012 13:12:02 -0400 (EDT)
Received: by iajr24 with SMTP id r24so5872584iaj.14
        for <linux-mm@kvack.org>; Mon, 02 Apr 2012 10:12:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAOJsxLGJorTZL7OhNzfpX0T1LQHrLs59LVr1WYX_8VAi8BF35g@mail.gmail.com>
References: <20120316144028.036474157@chello.nl>
	<4F670325.7080700@redhat.com>
	<1332155527.18960.292.camel@twins>
	<20120319130401.GI24602@redhat.com>
	<1332163591.18960.334.camel@twins>
	<20120319135745.GL24602@redhat.com>
	<4F673D73.90106@redhat.com>
	<20120319143002.GQ24602@redhat.com>
	<1332182523.18960.372.camel@twins>
	<4F69022D.3080300@redhat.com>
	<CAOJsxLHPc7QxdsUADikgeqQo7WVCzUD1KoHRT7Ngr7xXM_F7ig@mail.gmail.com>
	<4F79D9F1.7030504@redhat.com>
	<CAOJsxLGJorTZL7OhNzfpX0T1LQHrLs59LVr1WYX_8VAi8BF35g@mail.gmail.com>
Date: Mon, 2 Apr 2012 20:12:01 +0300
Message-ID: <CAOJsxLHYoAtxvcW1B47jGm4GYZpc1vB6+ovyCk0njU4LFXsaAg@mail.gmail.com>
Subject: Re: [RFC][PATCH 00/26] sched/numa
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Dan Smith <danms@us.ibm.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Apr 2, 2012 at 7:54 PM, Pekka Enberg <penberg@kernel.org> wrote:
> Sure, it's probably going to help for the kinds of workloads you're
> describing. I'm just wondering how typical they are in the real world.

I don't have a NUMA machine to test this with but it'd be interesting
to see how AutoNUMA and sched/numa affect DaCapo benchmarks:

http://dacapobench.org/

I guess benchmarks that represent typical JVM server workloads are
tomcat and tradesoap. You can run them easily with this small shell
script:

#!/bin/sh

JAR=dacapo-9.12-bach.jar

if [ ! -f $JAR ];
then
  wget http://sourceforge.net/projects/dacapobench/files/9.12-bach/$JAR/download
fi

java -jar $JAR tomcat tradesoap | grep PASSED

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
