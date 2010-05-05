Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 927576B0217
	for <linux-mm@kvack.org>; Wed,  5 May 2010 06:03:48 -0400 (EDT)
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20100505032033.GA19232@google.com>
References: <20100505032033.GA19232@google.com>
Subject: Re: rwsem: down_read_unfair() proposal
Date: Wed, 05 May 2010 11:03:40 +0100
Message-ID: <22933.1273053820@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Michel Lespinasse <walken@google.com>
Cc: dhowells@redhat.com, Andrew Morton <akpm@google.com>, Linux-MM <linux-mm@kvack.org>, Ying Han <yinghan@google.com>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>


If the system is as heavily loaded as you say, how do you prevent writer
starvation?  Or do things just grind along until sufficient threads are queued
waiting for a write lock?

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
