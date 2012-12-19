Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 174A26B002B
	for <linux-mm@kvack.org>; Wed, 19 Dec 2012 16:52:56 -0500 (EST)
Received: by mail-pb0-f42.google.com with SMTP id rp2so1507747pbb.29
        for <linux-mm@kvack.org>; Wed, 19 Dec 2012 13:52:55 -0800 (PST)
Date: Wed, 19 Dec 2012 13:52:53 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2] mm: clean up transparent hugepage sysfs error
 messages
In-Reply-To: <1355921460-28501-1-git-send-email-jeder@redhat.com>
Message-ID: <alpine.DEB.2.00.1212191352330.32757@chino.kir.corp.google.com>
References: <1355921460-28501-1-git-send-email-jeder@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeremy Eder <jeder@redhat.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org

On Wed, 19 Dec 2012, Jeremy Eder wrote:

> This patch clarifies error messages and corrects a few typos
> in the transparent hugepage sysfs init code.
> 
> Signed-off-by: Jeremy Eder <jeder@redhat.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
