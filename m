Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id DE18F9000BD
	for <linux-mm@kvack.org>; Thu, 22 Sep 2011 17:53:07 -0400 (EDT)
Date: Thu, 22 Sep 2011 17:53:01 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: kernel crash
Message-ID: <20110922215301.GA752@redhat.com>
References: <1316717125.61795.YahooMailClassic@web162017.mail.bf1.yahoo.com>
 <20110922212432.GB25623@redhat.com>
 <alpine.DEB.2.00.1109221430450.2635@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1109221430450.2635@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: M <sah_8@yahoo.com>, linux-mm@kvack.org

On Thu, Sep 22, 2011 at 02:38:47PM -0700, David Rientjes wrote:

 > The problem is this:
 > 
 > Sep 20 19:39:19 host2 kernel: [1933000.196980] [ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name
 > ...
 > Sep 20 19:39:19 host2 kernel: [1933000.197559] [13918]   507 13918 17992270  7758558   4     -17         -1000 root.exe
 > 
 > root.exe is has about 29.5GB of the 32GB available memory in RAM, and it's 
 > set to have a /proc/13918/oom_score_adj of -1000 meaning it's not eligible 
 > for oom killing.  So the kernel panics rather than kill the task.
 > 
 > There's not much the kernel can be expected to do in such a configuration, 
 > you've simply exhausted all RAM and swap.  You can set 
 > /proc/pid/oom_score_adj to not be -1000 so that it is at least eligible to 
 > be killed in these circumstances rather than panic the machine, but the VM 
 > will continue to oom under this configuration.

It's surprising that the same workload in 32-bit works.

Manoj, is root.exe recompiled for 64-bit ? I'm wondering if it's just that
the expansion of a lot of unsigned longs are causing increased memory use vs
the original 32bit use-case.

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
