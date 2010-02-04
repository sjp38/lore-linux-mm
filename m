Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 8D26F6B0078
	for <linux-mm@kvack.org>; Thu,  4 Feb 2010 17:31:42 -0500 (EST)
From: Frans Pop <elendil@planet.nl>
Subject: Re: Improving OOM killer
Date: Thu, 4 Feb 2010 23:31:31 +0100
References: <201002012302.37380.l.lunak@suse.cz> <20100203170127.GH19641@balbir.in.ibm.com> <alpine.DEB.2.00.1002031021190.14088@chino.kir.corp.google.com> <201002032355.01260.l.lunak@suse.cz> <alpine.DEB.2.00.1002031600490.27918@chino.kir.corp.google.com> <4B6A1241.60009@redhat.com> <4B6A1241.60009@redhat.com> <alpine.DEB.2.00.1002041339220.6071@chino.kir.corp.google.com>
In-reply-To: <alpine.DEB.2.00.1002041339220.6071@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <201002042331.34086.elendil@planet.nl>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: riel@redhat.com, l.lunak@suse.cz, balbir@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, npiggin@suse.de, jkosina@suse.cz
List-ID: <linux-mm.kvack.org>

David Rientjes wrote:
> It's clear that the forkbomb threshold would need to be definable from
> userspace and probably default to something high such as 1000.
> 
> Keep in mind that we're in the oom killer here, though.  So we're out of
> memory and we need to kill something; should Apache, Oracle, and postgres
> not be penalized for their cost of running by factoring in something like
> this?
> 
> (lowest rss size of children) * (# of first-generation children) /
>                    (forkbomb threshold)

Shouldn't fork bomb detection take into account the age of children?
After all, long running processes with a lot of long running children are 
rather unlikely to be runaway fork _bombs_.

Children for desktop environments are more likely to be long running than 
e.g. a server process that's being DOSed.
The goal of the OOM killer is IIUC trying to identify the process thats 
causing the immediate problem so in this example it should prefer latter.

Cheers,
FJP

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
