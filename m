Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 0FF9E6B00CB
	for <linux-mm@kvack.org>; Wed, 14 Dec 2011 21:42:09 -0500 (EST)
Received: by yhgm50 with SMTP id m50so155218yhg.14
        for <linux-mm@kvack.org>; Wed, 14 Dec 2011 18:42:08 -0800 (PST)
Date: Wed, 14 Dec 2011 18:42:05 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm/mempolicy.c: use enum value MPOL_REBIND_ONCE instead
 of 0 in mpol_rebind_policy
In-Reply-To: <4EE8A461.2080406@gmail.com>
Message-ID: <alpine.DEB.2.00.1112141840550.27595@chino.kir.corp.google.com>
References: <4EE8A461.2080406@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wang Sheng-Hui <shhuiw@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 14 Dec 2011, Wang Sheng-Hui wrote:

> We have enum definition in mempolicy.h: MPOL_REBIND_ONCE.
> It should replace the magic number 0 for step comparison in
> function mpol_rebind_policy.
> 
> Signed-off-by: Wang Sheng-Hui <shhuiw@gmail.com>

Acked-by: David Rientjes <rientjes@google.com>

Tip: when proposing patches, it's helpful to run scripts/get_maintainer.pl 
on your patch file from git to determine who should be cc'd on the email.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
