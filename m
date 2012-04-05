Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 9790D6B007E
	for <linux-mm@kvack.org>; Thu,  5 Apr 2012 17:41:29 -0400 (EDT)
Received: by iajr24 with SMTP id r24so3154331iaj.14
        for <linux-mm@kvack.org>; Thu, 05 Apr 2012 14:41:28 -0700 (PDT)
Date: Thu, 5 Apr 2012 14:41:26 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/2] Documentation: mm: Fix path to extfrag_index in
 vm.txt
In-Reply-To: <1333644489-31466-2-git-send-email-standby24x7@gmail.com>
Message-ID: <alpine.DEB.2.00.1204051440280.17852@chino.kir.corp.google.com>
References: <1333644489-31466-1-git-send-email-standby24x7@gmail.com> <1333644489-31466-2-git-send-email-standby24x7@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Masanari Iida <standby24x7@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 6 Apr 2012, Masanari Iida wrote:

> The path for extfrag_index has not been updated even after it moved
> to under /sys. This patch fixed the path.
> 

The path looks good, but I think it would be better to also add that you 
must mount debugfs for this to be available there.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
