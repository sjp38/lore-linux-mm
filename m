Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 5671A6B0031
	for <linux-mm@kvack.org>; Tue, 24 Sep 2013 23:11:44 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id y10so5452413pdj.11
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 20:11:44 -0700 (PDT)
Date: Tue, 24 Sep 2013 23:11:27 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: [patch] mm, mempolicy: make mpol_to_str robust and always succeed
Message-ID: <20130925031127.GA4210@redhat.com>
References: <5215639D.1080202@asianux.com>
 <5227CF48.5080700@asianux.com>
 <alpine.DEB.2.02.1309241957280.26415@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1309241957280.26415@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Chen Gang <gang.chen@asianux.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Sep 24, 2013 at 07:58:22PM -0700, David Rientjes wrote:

 >  	case MPOL_BIND:
 > -		/* Fall through */
 >  	case MPOL_INTERLEAVE:
 >  		nodes = pol->v.nodes;
 >  		break;

Any reason not to leave this ?

"missing break" is the 2nd most common thing that coverity picks up.
Most of them are false positives like the above, but the lack of annotations
in our source makes it time-consuming to pick through them all to find the
real bugs.

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
