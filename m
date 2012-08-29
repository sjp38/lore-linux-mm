Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 5550C6B0068
	for <linux-mm@kvack.org>; Tue, 28 Aug 2012 23:04:04 -0400 (EDT)
Received: by pbbro12 with SMTP id ro12so319213pbb.14
        for <linux-mm@kvack.org>; Tue, 28 Aug 2012 20:04:03 -0700 (PDT)
Date: Tue, 28 Aug 2012 20:04:01 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] oom: remove deprecated oom_adj
In-Reply-To: <1345819351.2574.6.camel@offbook>
Message-ID: <alpine.DEB.2.00.1208282003490.24229@chino.kir.corp.google.com>
References: <1345819351.2574.6.camel@offbook>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <dave@gnu.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Fri, 24 Aug 2012, Davidlohr Bueso wrote:

> The deprecated /proc/<pid>/oom_adj is scheduled for removal this month.
> 
> Signed-off-by: Davidlohr Bueso <dave@gnu.org>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
