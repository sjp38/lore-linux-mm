Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id F23ED6B016C
	for <linux-mm@kvack.org>; Fri, 26 Aug 2011 14:09:24 -0400 (EDT)
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id p7QI9LcJ010259
	for <linux-mm@kvack.org>; Fri, 26 Aug 2011 11:09:21 -0700
Received: from pzk32 (pzk32.prod.google.com [10.243.19.160])
	by wpaz9.hot.corp.google.com with ESMTP id p7QI9HVq024479
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 26 Aug 2011 11:09:19 -0700
Received: by pzk32 with SMTP id 32so5159361pzk.5
        for <linux-mm@kvack.org>; Fri, 26 Aug 2011 11:09:16 -0700 (PDT)
Date: Fri, 26 Aug 2011 11:09:14 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] oom: skip frozen tasks
In-Reply-To: <4E576E6F.1030909@openvz.org>
Message-ID: <alpine.DEB.2.00.1108261106570.13943@chino.kir.corp.google.com>
References: <20110823073101.6426.77745.stgit@zurg> <alpine.DEB.2.00.1108231313520.21637@chino.kir.corp.google.com> <20110824101927.GB3505@tiehlicka.suse.cz> <alpine.DEB.2.00.1108241226550.31357@chino.kir.corp.google.com> <20110825091920.GA22564@tiehlicka.suse.cz>
 <20110825151818.GA4003@redhat.com> <20110825164758.GB22564@tiehlicka.suse.cz> <alpine.DEB.2.00.1108251404130.18747@chino.kir.corp.google.com> <4E574CA5.4010701@openvz.org> <alpine.DEB.2.00.1108260209050.14732@chino.kir.corp.google.com>
 <4E576E6F.1030909@openvz.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Michal Hocko <mhocko@suse.cz>, Oleg Nesterov <oleg@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>

On Fri, 26 Aug 2011, Konstantin Khlebnikov wrote:

> Maybe just fix this "panic" logic? OOM killer should panic only on global
> memory shortage.
> 

NO, it shouldn't, we actually rely quite extensively on cpusets filled 
with OOM_DISABLE threads to panic because the job scheduler would be 
unresponsive in such a condition and it'd much better to panic and reboot 
than to brick the machine.  I'm not sure where you're getting all your 
information from, but please don't pass it off as principles.

You can set the panic logic to be whatever you want with 
/proc/sys/vm/panic_on_oom.  See Documentation/filesystems/proc.txt for 
more information.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
