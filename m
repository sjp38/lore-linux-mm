Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 2488E6B004D
	for <linux-mm@kvack.org>; Fri, 20 Jan 2012 17:45:15 -0500 (EST)
Date: Fri, 20 Jan 2012 14:45:13 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 12309] Large I/O operations result in poor interactive
 performance and high iowait times
Message-Id: <20120120144513.f457a58d.akpm@linux-foundation.org>
In-Reply-To: <201201201611.q0KGBPf6029256@bugzilla.kernel.org>
References: <bug-12309-27@https.bugzilla.kernel.org/>
	<201201201611.q0KGBPf6029256@bugzilla.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Wu Fengguang <fengguang.wu@intel.com>

On Fri, 20 Jan 2012 16:11:25 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=12309

We've had some recent updates to the world's largest bug report. 
Apparently our large-writer-paralyses-the-machine problems have
worsened in recent kernels.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
