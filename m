Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 4CA986B0073
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 18:01:15 -0500 (EST)
Received: by iacb35 with SMTP id b35so2033305iac.14
        for <linux-mm@kvack.org>; Thu, 05 Jan 2012 15:01:14 -0800 (PST)
Date: Thu, 5 Jan 2012 15:01:10 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 3.2.0-rc1 0/3] Used Memory Meter pseudo-device and related
 changes in MM
In-Reply-To: <CAOJsxLH8s5cjUSdpBpLNDvtNaJjnhBwNKOMXZPzUD=XDivr7Rg@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1201051458560.10521@chino.kir.corp.google.com>
References: <cover.1325696593.git.leonid.moiseichuk@nokia.com> <20120104195612.GB19181@suse.de> <4F04B3F0.6080103@redhat.com> <CAOJsxLH8s5cjUSdpBpLNDvtNaJjnhBwNKOMXZPzUD=XDivr7Rg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Greg KH <gregkh@suse.de>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cesarb@cesarb.net, kamezawa.hiroyu@jp.fujitsu.com, emunson@mgebm.net, aarcange@redhat.com, mel@csn.ul.ie, dima@android.com, rebecca@android.com, san@google.com, akpm@linux-foundation.org, vesa.jaaskelainen@nokia.com, Minchan Kim <minchan@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>

On Wed, 4 Jan 2012, Pekka Enberg wrote:

> And even if people want to support multiple ABIs and fight it out to
> see which one wins, we should factor out the generic parts and put
> them under mm/*.c and not hide them in random modules.
> 

Agreed.  This came up recently when another lowmem killer was proposed and 
the suggestion was to enable the memory controller to be able to have the 
memory threshold notifications with eventfd(2) and cgroup.event_control.  
It would be very nice to have a generic lowmem notifier (like 
/dev/mem_notify that has been reworked several times in the past) rather 
than tying it to a particular cgroup, especially when that cgroup incurs a 
substantial overhead for embedded users.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
