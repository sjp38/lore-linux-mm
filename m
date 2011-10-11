Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id C5BD46B002D
	for <linux-mm@kvack.org>; Tue, 11 Oct 2011 10:47:47 -0400 (EDT)
Message-ID: <4E9457BA.8060002@jp.fujitsu.com>
Date: Tue, 11 Oct 2011 10:50:34 -0400
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [patch v2] oom: thaw threads if oom killed thread is frozen before
 deferring
References: <alpine.DEB.2.00.1110071954040.13992@chino.kir.corp.google.com> <alpine.DEB.2.00.1110071958200.13992@chino.kir.corp.google.com> <CAHGf_=rQN35sM6SLLz9NrgSooKhmsVhR2msEY3jxnLSj+SAcXQ@mail.gmail.com> <20111011063336.GA23284@tiehlicka.suse.cz>
In-Reply-To: <20111011063336.GA23284@tiehlicka.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz
Cc: rientjes@google.com, akpm@linux-foundation.org, oleg@redhat.com, kamezawa.hiroyu@jp.fujitsu.com, rjw@sisk.pl, linux-mm@kvack.org, htejun@gmail.com

>> Looks ok to me.
>> Michal, do you agree this patch?
> 
> The patch looks good but we still need other 2 patches
> (http://comments.gmane.org/gmane.linux.kernel.mm/68578), right?
> 
> Anyway, I thought that we agreed on the other approach suggested by
> Tejun (make frozen tasks oom killable without thawing). Even in that
> case we want the first patch
> (http://permalink.gmane.org/gmane.linux.kernel.mm/68576).

I'm sorry. I still don't catch up the above long thread. Could you
please resend your final patch again? I'll review it.

Thank you.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
