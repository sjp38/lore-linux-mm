Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id D3D756B004A
	for <linux-mm@kvack.org>; Thu, 26 Apr 2012 18:20:36 -0400 (EDT)
Received: by iajr24 with SMTP id r24so190594iaj.14
        for <linux-mm@kvack.org>; Thu, 26 Apr 2012 15:20:36 -0700 (PDT)
Date: Thu, 26 Apr 2012 15:20:34 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: 3.4-rc4 oom killer out of control.
In-Reply-To: <20120426215257.GA12908@redhat.com>
Message-ID: <alpine.DEB.2.00.1204261517100.28376@chino.kir.corp.google.com>
References: <20120426193551.GA24968@redhat.com> <alpine.DEB.2.00.1204261437470.28376@chino.kir.corp.google.com> <20120426215257.GA12908@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>, linux-mm@kvack.org, Linux Kernel <linux-kernel@vger.kernel.org>

On Thu, 26 Apr 2012, Dave Jones wrote:

> /sys/kernel/mm/ksm/full_scans is increasing constantly
> 
> full_scans: 146370
> pages_shared: 1
> pages_sharing: 4
> pages_to_scan: 1250
> pages_unshared: 867
> pages_volatile: 1
> run: 1
> sleep_millisecs: 20
> 

full_scans is just a counter of how many times it has scanned mergable 
memory so it should be increasing constantly.  Whether pages_to_scan == 
1250 and sleep_millisecs == 20 is good for your system is unknown.  You 
may want to try disabling ksm entirely (echo 0 > /sys/kernel/mm/ksm/run) 
to see if it significantly increases responsiveness for your workload.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
