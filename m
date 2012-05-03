Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 9D0FA6B0044
	for <linux-mm@kvack.org>; Thu,  3 May 2012 18:29:55 -0400 (EDT)
Date: Thu, 3 May 2012 18:29:49 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: 3.4-rc4 oom killer out of control.
Message-ID: <20120503222949.GA13762@redhat.com>
References: <20120426193551.GA24968@redhat.com>
 <alpine.DEB.2.00.1204261437470.28376@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1205031513400.1631@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1205031513400.1631@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, Linux Kernel <linux-kernel@vger.kernel.org>

On Thu, May 03, 2012 at 03:14:09PM -0700, David Rientjes wrote:

 > Dave, did you get a chance to test this out?  It's something we'll want in 
 > the oom killer so if I can add your Tested-by it would be great.  Thanks!

Yes, this seems to be an improvement in my case (the fuzzer got killed every time
rather than arbitary system processes).

Feel free to add my Tested-by:

thanks,

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
