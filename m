Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 5BF916B004A
	for <linux-mm@kvack.org>; Thu, 26 Apr 2012 18:49:09 -0400 (EDT)
Received: by yenm8 with SMTP id m8so129749yen.14
        for <linux-mm@kvack.org>; Thu, 26 Apr 2012 15:49:08 -0700 (PDT)
Date: Thu, 26 Apr 2012 15:49:06 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: 3.4-rc4 oom killer out of control.
In-Reply-To: <20120426224419.GA13598@redhat.com>
Message-ID: <alpine.DEB.2.00.1204261547250.15785@chino.kir.corp.google.com>
References: <20120426193551.GA24968@redhat.com> <alpine.DEB.2.00.1204261437470.28376@chino.kir.corp.google.com> <20120426215257.GA12908@redhat.com> <alpine.DEB.2.00.1204261517100.28376@chino.kir.corp.google.com> <20120426224419.GA13598@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>, linux-mm@kvack.org, Linux Kernel <linux-kernel@vger.kernel.org>

On Thu, 26 Apr 2012, Dave Jones wrote:

> Disabling it stops it hogging the cpu obviously, but there's still 8G of RAM
> and 1G of used swap sitting around doing something.
> 

Right, I eluded to this in another email because the rss sizes from your 
oom log weren't necessarily impressive.  Could you post the output of 
/proc/meminfo?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
