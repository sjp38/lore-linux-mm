Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 981206B0071
	for <linux-mm@kvack.org>; Fri, 19 Nov 2010 12:59:26 -0500 (EST)
Date: Fri, 19 Nov 2010 11:59:23 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: percpu: Implement this_cpu_add,sub,dec,inc_return
In-Reply-To: <alpine.DEB.2.00.1011191108240.3976@router.home>
Message-ID: <alpine.DEB.2.00.1011191158240.4423@router.home>
References: <alpine.DEB.2.00.1011091124490.9898@router.home>  <alpine.DEB.2.00.1011100939530.23566@router.home>  <1290018527.2687.108.camel@edumazet-laptop>  <alpine.DEB.2.00.1011190941380.32655@router.home>  <1290181870.3034.136.camel@edumazet-laptop>
 <alpine.DEB.2.00.1011190958230.2360@router.home> <1290183158.3034.145.camel@edumazet-laptop> <alpine.DEB.2.00.1011191108240.3976@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 19 Nov 2010, Christoph Lameter wrote:

> Ok so rename the macros to this_cpu_return_inc/dec/add/sub?

Actually this is fetchadd. So call I will call this this_cpu_fetch_add/inc/dec/sub.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
