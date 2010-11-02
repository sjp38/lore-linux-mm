Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id BC2E76B016F
	for <linux-mm@kvack.org>; Tue,  2 Nov 2010 10:29:33 -0400 (EDT)
Received: by pwi1 with SMTP id 1so1922464pwi.14
        for <linux-mm@kvack.org>; Tue, 02 Nov 2010 07:29:31 -0700 (PDT)
Subject: Re: [PATCH]oom-kill: direct hardware access processes should get
 bonus
From: "Figo.zhang" <figo1802@gmail.com>
In-Reply-To: <alpine.DEB.2.00.1011012008160.9383@chino.kir.corp.google.com>
References: <1288662213.10103.2.camel@localhost.localdomain>
	 <alpine.DEB.2.00.1011012008160.9383@chino.kir.corp.google.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 02 Nov 2010 22:24:54 +0800
Message-ID: <1288707894.19865.1.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>


> 
> Which applications are you referring to that cannot gracefully exit if 
> killed?

like Xorg server, if xorg server be killed, the gnome desktop will be
crashed.


> 
> CAP_SYS_RAWIO had a much more dramatic impact in the previous heuristic to 
> such a point that it would often allow memory hogging tasks to elude the 
> oom killer at the expense of innocent tasks.  I'm not sure this is the 
> best way to go.

is it some experiments for demonstration the  CAP_SYS_RAWIO will elude
the oom killer?




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
