Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id E23AB8D0017
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 22:27:29 -0500 (EST)
Message-ID: <4CE0A87E.1030304@leadcoretech.com>
Date: Mon, 15 Nov 2010 11:26:54 +0800
From: "Figo.zhang" <zhangtianfei@leadcoretech.com>
MIME-Version: 1.0
Subject: Re: [PATCH] Revert oom rewrite series
References: <1289402093.10699.25.camel@localhost.localdomain> <1289402666.10699.28.camel@localhost.localdomain> <20101114141913.E019.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1011141330120.22262@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1011141330120.22262@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Figo.zhang" <figo1802@gmail.com>, lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

 >Nothing to say, really.  Seems each time we're told about a bug or a
 >regression, David either fixes the bug or points out why it wasn't a
 >bug or why it wasn't a regression or how it was a deliberate behaviour
 >change for the better.

 >I just haven't seen any solid reason to be concerned about the state of
 >the current oom-killer, sorry.

 >I'm concerned that you're concerned!  A lot.  When someone such as
 >yourself is unhappy with part of MM then I sit up and pay attention.
 >But after all this time I simply don't understand the technical issues
 >which you're seeing here.

we just talk about oom-killer technical issues.

i am doubt that a new rewrite but the athor canot provide some evidence 
and experiment result, why did you do that? what is the prominent change 
for your new algorithm?

as KOSAKI Motohiro said, "you removed CAP_SYS_RESOURCE condition with 
ZERO explanation".

David just said that pls use userspace tunable for protection by 
oom_score_adj. but may i ask question:

1. what is your innovation for your new algorithm, the old one have the 
same way for user tunable oom_adj.

2. if server like db-server/financial-server have huge import processes 
(such as root/hardware access processes)want to be protection, you let 
the administrator to find out which processes should be protection. you
will let the  financial-server administrator huge crazy!! and lose so 
many money!! ^~^

3. i see your email in LKML, you just said
"I have repeatedly said that the oom killer no longer kills KDE when run 
on my desktop in the presence of a memory hogging task that was written 
specifically to oom the machine."
http://thread.gmane.org/gmane.linux.kernel.mm/48998

so you just test your new oom_killer algorithm on your desktop with KDE, 
so have you provide the detail how you do the test? is it do the
experiment again for anyone and got the same result as your comment ?

as KOSAKI Motohiro said, in reality word, it we makes 5-6 brain 
simulation, embedded, desktop, web server,db server, hpc, finance. 
Different workloads certenally makes big impact. have you do those
experiments?

i think that technology should base on experiment not on imagine.


Best,
Figo.zhang




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
