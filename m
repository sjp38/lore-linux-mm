Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id QAA21377
	for <linux-mm@kvack.org>; Tue, 11 Mar 2003 16:34:15 -0800 (PST)
Date: Tue, 11 Mar 2003 16:29:22 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: [Fwd: [BUG][2.4.18+] kswapd assumes swapspace exists]
Message-Id: <20030311162922.373a2414.akpm@digeo.com>
In-Reply-To: <3E6E49BD.1050701@google.com>
References: <3E6E49BD.1050701@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ross Biro <rossb@google.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ross Biro <rossb@google.com> wrote:
>
> I posted this to the LKML and got no response.  There is definitely an 
> MM bug here.  My test program (should be attached) has run over 330 
> times in a row with the change while it rarely made more than twice with 
> out the change.
> 

Makes sense.  There's a fix for this in the -aa kernels, but it may have been
accidental.

There's no point in bringing these pages onto the inactive list at all. 
Suggest you look at keeping them on the active list in refill_inactive().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
