Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 907626B002D
	for <linux-mm@kvack.org>; Tue, 11 Oct 2011 11:54:49 -0400 (EDT)
Message-ID: <4E94676F.2030302@jp.fujitsu.com>
Date: Tue, 11 Oct 2011 11:57:35 -0400
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [patch v2] oom: thaw threads if oom killed thread is frozen before
 deferring
References: <alpine.DEB.2.00.1110071954040.13992@chino.kir.corp.google.com> <alpine.DEB.2.00.1110071958200.13992@chino.kir.corp.google.com> <CAHGf_=rQN35sM6SLLz9NrgSooKhmsVhR2msEY3jxnLSj+SAcXQ@mail.gmail.com> <20111011063336.GA23284@tiehlicka.suse.cz> <4E9457BA.8060002@jp.fujitsu.com> <20111011151412.GF23284@tiehlicka.suse.cz>
In-Reply-To: <20111011151412.GF23284@tiehlicka.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz
Cc: rientjes@google.com, akpm@linux-foundation.org, oleg@redhat.com, kamezawa.hiroyu@jp.fujitsu.com, rjw@sisk.pl, linux-mm@kvack.org, htejun@gmail.com

> To sum up. There are 3 patches flying around at the moment.
> http://permalink.gmane.org/gmane.linux.kernel.mm/68576
> http://permalink.gmane.org/gmane.linux.kernel.mm/68577
> http://permalink.gmane.org/gmane.linux.kernel.mm/68583
> 
> They are approaching the problem by thawing oom selected frozen task.
> 
> Tejun mentioned his work (sorry I do not have a link to patches) that
> should enable direct killing frozen tasks. This would mean that we do
> not need any special handling from the OOM code paths AFAIU. This would
> be much better of course and I guess we can wait for them for 3.2.
> 
> Does this make sense?

I don't find any bad in the idea. So, I have two questions.

 o Who are writing such patch now?

 o Should we drop current drientjes patch?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
