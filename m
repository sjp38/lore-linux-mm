Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1EFF26B0071
	for <linux-mm@kvack.org>; Tue, 26 Oct 2010 15:39:58 -0400 (EDT)
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id o9QJcA03016271
	for <linux-mm@kvack.org>; Tue, 26 Oct 2010 12:38:10 -0700
Received: from pxi11 (pxi11.prod.google.com [10.243.27.11])
	by wpaz9.hot.corp.google.com with ESMTP id o9QJc4Ff027554
	for <linux-mm@kvack.org>; Tue, 26 Oct 2010 12:38:09 -0700
Received: by pxi11 with SMTP id 11so1018726pxi.8
        for <linux-mm@kvack.org>; Tue, 26 Oct 2010 12:38:04 -0700 (PDT)
Date: Tue, 26 Oct 2010 12:37:59 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [resend][PATCH 2/4] Revert "oom: deprecate oom_adj tunable"
In-Reply-To: <20101026220237.B7DA.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1010261234230.5578@chino.kir.corp.google.com>
References: <20101025122723.916D.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1010251338081.21737@chino.kir.corp.google.com> <20101026220237.B7DA.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 26 Oct 2010, KOSAKI Motohiro wrote:

> > NACK as a logical follow-up to my NACK for "oom: remove totalpage 
> > normalization from oom_badness()"
> 
> Huh?
> 
> I requested you show us justification. BUT YOU DIDNT. If you have any 
> usecase, show us RIGHT NOW. 
> 

The new tunable added in 2.6.36, /proc/pid/oom_score_adj, is necessary for 
the units that the badness score now uses.  We need a tunable with a much 
higher resolution than the oom_adj scale from -16 to +15, and one that 
scales linearly as opposed to exponentially.  Since that tunable is much 
more powerful than the oom_adj implementation, which never made any real 
sense for defining oom killing priority for any purpose other than 
polarization, the old tunable is deprecated for two years.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
