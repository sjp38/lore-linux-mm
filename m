Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 948056B007D
	for <linux-mm@kvack.org>; Wed,  3 Feb 2010 09:49:27 -0500 (EST)
Message-ID: <4B698CEE.5020806@redhat.com>
Date: Wed, 03 Feb 2010 09:49:18 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: Improving OOM killer
References: <201002012302.37380.l.lunak@suse.cz>
In-Reply-To: <201002012302.37380.l.lunak@suse.cz>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Lubos Lunak <l.lunak@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Nick Piggin <npiggin@suse.de>, Jiri Kosina <jkosina@suse.cz>
List-ID: <linux-mm.kvack.org>

On 02/01/2010 05:02 PM, Lubos Lunak wrote:

>   In other words, use VmRSS for measuring memory usage instead of VmSize, and
> remove child accumulating.

I agree with removing the child accumulating code.  That code can
do a lot of harm with databases like postgresql, or cause the
system's main service (eg. httpd) to be killed when a broken cgi
script used up too much memory.

IIRC the child accumulating code was introduced to deal with
malicious code (fork bombs), but it makes things worse for the
(much more common) situation of a system without malicious
code simply running out of memory due to being very busy.

I have no strong opinion on using RSS vs VmSize.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
