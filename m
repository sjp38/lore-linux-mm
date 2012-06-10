Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 718976B005C
	for <linux-mm@kvack.org>; Sat,  9 Jun 2012 22:21:04 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so4996791pbb.14
        for <linux-mm@kvack.org>; Sat, 09 Jun 2012 19:21:03 -0700 (PDT)
Date: Sat, 9 Jun 2012 19:21:01 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: oomkillers gone wild.
In-Reply-To: <20120608210330.GA21010@redhat.com>
Message-ID: <alpine.DEB.2.00.1206091920140.7832@chino.kir.corp.google.com>
References: <20120604152710.GA1710@redhat.com> <alpine.DEB.2.00.1206041629500.7769@chino.kir.corp.google.com> <20120605174454.GA23867@redhat.com> <alpine.DEB.2.00.1206081313000.19054@chino.kir.corp.google.com> <20120608210330.GA21010@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Fri, 8 Jun 2012, Dave Jones wrote:

>  > On a system not under oom conditions, i.e. before you start trinity, can 
>  > you send the output of
>  > 
>  > 	cat /proc/$(pidof dbus-daemon)/oom_score{_adj,}
>  > 	grep RSS /proc/$(pidof dbus-daemon)/status
> 
> # cat /proc/$(pidof dbus-daemon)/oom_score{_adj,}
> -900
> 7441500919753
> # grep RSS /proc/$(pidof dbus-daemon)/status
> VmRSS:	    1660 kB

I'm suspecting you don't have my patch that changes the type of the 
automatic variable in oom_badness() to signed.  Could you retry this with 
that patch or pull 3.5-rc2 which already includes it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
