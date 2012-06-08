Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id B02776B0062
	for <linux-mm@kvack.org>; Fri,  8 Jun 2012 16:15:53 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so3661160pbb.14
        for <linux-mm@kvack.org>; Fri, 08 Jun 2012 13:15:53 -0700 (PDT)
Date: Fri, 8 Jun 2012 13:15:50 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: oomkillers gone wild.
In-Reply-To: <20120605174454.GA23867@redhat.com>
Message-ID: <alpine.DEB.2.00.1206081313000.19054@chino.kir.corp.google.com>
References: <20120604152710.GA1710@redhat.com> <alpine.DEB.2.00.1206041629500.7769@chino.kir.corp.google.com> <20120605174454.GA23867@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Tue, 5 Jun 2012, Dave Jones wrote:

> Still doesn't seem right..
> 
> eg..
> 
> [42309.542776] [ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name
> ..
> [42309.553933] [  500]    81   500     5435        1   4     -13          -900 dbus-daemon
> ..
> [42309.597531] [ 9054]  1000  9054   528677    14540   3       0             0 trinity-child3
> ..
> 
> [42309.643057] Out of memory: Kill process 500 (dbus-daemon) score 511952 or sacrifice child
> [42309.643620] Killed process 500 (dbus-daemon) total-vm:21740kB, anon-rss:0kB, file-rss:4kB
> 
> and a slew of similar 'wrong process' death spiral kills follows..
> 

On a system not under oom conditions, i.e. before you start trinity, can 
you send the output of

	cat /proc/$(pidof dbus-daemon)/oom_score{_adj,}
	grep RSS /proc/$(pidof dbus-daemon)/status

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
