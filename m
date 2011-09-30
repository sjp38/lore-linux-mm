Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 44BB79000BD
	for <linux-mm@kvack.org>; Fri, 30 Sep 2011 17:41:07 -0400 (EDT)
MIME-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 8bit
Date: Fri, 30 Sep 2011 17:40:33 -0400
From: Eric B Munson <emunson@mgebm.net>
Subject: Re: [PATCH 0/9] V2: idle page tracking / working set estimation
In-Reply-To: <CANN689EN8KsBZj_9cABjJoZNou_UegZ8uqB4Lx=uM-B_4aCd7A@mail.gmail.com>
References: <1317170947-17074-1-git-send-email-walken@google.com>
 <20110929164319.GA3509@mgebm.net>
 <CANN689H1G-USQYQrOTb47Hrc7KMjLdxkppYCDKsTUy5WhuRs7w@mail.gmail.com>
 <4186d5662b3fb21af1b45f8a335414d3@mgebm.net>
 <20110930181914.GA17817@mgebm.net>
 <CANN689EN8KsBZj_9cABjJoZNou_UegZ8uqB4Lx=uM-B_4aCd7A@mail.gmail.com>
Message-ID: <7bf74fcb33ce31bcc933db6d90b03733@mgebm.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Balbir Singh <bsingharora@gmail.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Michael Wolf <mjwolf@us.ibm.com>

 On Fri, 30 Sep 2011 14:16:25 -0700, Michel Lespinasse wrote:
> On Fri, Sep 30, 2011 at 11:19 AM, Eric B Munson <emunson@mgebm.net> 
> wrote:
>> I am able to recreate on a second desktop I have here (same model 
>> CPU but a
>> different MB so I am fairly sure it isn't dying hardware). A It looks 
>> to me like
>> a CPU softlocks and it stalls the process active there, so most 
>> recently that
>> was XOrg. A The machine lets me login via ssh for a few minutes, but 
>> things like
>> ps and cat or /proc files will start to work and give some output 
>> but hang.
>> I cannot call reboot, nor can I sync the fs and reboot via SysRq. 
>> A My next step
>> is to setup a netconsole to see if anything comes out in the syslog 
>> that I
>> cannot see.
>
> I haven't had time to try & reproduce locally yet (apologies - things
> have been coming up at me).
>
> But a prime suspect would be a bad interaction with
> CONFIG_MEMORY_HOTPLUG, as Kamezama remarked in his reply to patch 4. 
> I
> think this could be the most likely cause of what you're observing.

 I will try disabling Memory Hotplug on Monday and let you know if that 
 helps.

 Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
