Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id BBE956B0078
	for <linux-mm@kvack.org>; Wed, 10 Feb 2010 21:38:14 -0500 (EST)
Message-ID: <4B7320BF.2020800@redhat.com>
Date: Wed, 10 Feb 2010 16:10:23 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: Improving OOM killer
References: <201002012302.37380.l.lunak@suse.cz> <4B6B4500.3010603@redhat.com> <alpine.DEB.2.00.1002041410300.16391@chino.kir.corp.google.com> <201002102154.43231.l.lunak@suse.cz>
In-Reply-To: <201002102154.43231.l.lunak@suse.cz>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Lubos Lunak <l.lunak@suse.cz>
Cc: David Rientjes <rientjes@google.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Jiri Kosina <jkosina@suse.cz>
List-ID: <linux-mm.kvack.org>

On 02/10/2010 03:54 PM, Lubos Lunak wrote:

>   Which however can mean that not killing this system daemon will be traded for
> DoS-ing the whole system, if the daemon keeps spawning new children as soon
> as the OOM killer frees up resources for them.

Killing the system daemon *is* a DoS.

It would stop eg. the database or the web server, which is
generally the main task of systems that run a database or
a web server.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
