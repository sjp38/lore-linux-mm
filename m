Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1B5106B023E
	for <linux-mm@kvack.org>; Wed, 19 May 2010 18:14:55 -0400 (EDT)
Received: from hpaq12.eem.corp.google.com (hpaq12.eem.corp.google.com [172.25.149.12])
	by smtp-out.google.com with ESMTP id o4JMEo1W026434
	for <linux-mm@kvack.org>; Wed, 19 May 2010 15:14:51 -0700
Received: from pzk16 (pzk16.prod.google.com [10.243.19.144])
	by hpaq12.eem.corp.google.com with ESMTP id o4JMEmJI002750
	for <linux-mm@kvack.org>; Wed, 19 May 2010 15:14:49 -0700
Received: by pzk16 with SMTP id 16so4499697pzk.22
        for <linux-mm@kvack.org>; Wed, 19 May 2010 15:14:48 -0700 (PDT)
Date: Wed, 19 May 2010 15:14:42 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: oom killer rewrite
Message-ID: <alpine.DEB.2.00.1005191511140.27294@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

KOSAKI,

I've been notified that my entire oom killer rewrite has been dropped from 
-mm based solely on your feedback.  The problem is that I have absolutely 
no idea what issues you have with the changes that haven't already been 
addressed (nobody else does, either, it seems).

The last work I've done on the patches are to ask those involved in the 
review (including you) and linux-mm whether there were any outstanding 
issues that anyone has, and I've asked that twice.  I've received no 
response either time.

Please respond with a list of your objections to the rewrite (which is 
available at 
http://www.kernel.org/pub/linux/kernel/people/rientjes/oom-killer-rewrite
so we can move forward.

Thank you.

			David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
