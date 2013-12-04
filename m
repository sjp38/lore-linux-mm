Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 531D16B0037
	for <linux-mm@kvack.org>; Wed,  4 Dec 2013 03:40:31 -0500 (EST)
Received: by mail-pd0-f176.google.com with SMTP id w10so21897623pde.35
        for <linux-mm@kvack.org>; Wed, 04 Dec 2013 00:40:31 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id eb3si2124564pbc.206.2013.12.04.00.40.29
        for <linux-mm@kvack.org>;
        Wed, 04 Dec 2013 00:40:30 -0800 (PST)
Date: Wed, 4 Dec 2013 00:41:25 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH RFC] mm readahead: Fix the readahead fail in case of
 empty numa node
Message-Id: <20131204004125.a06f7dfc.akpm@linux-foundation.org>
In-Reply-To: <529EE811.5050306@linux.vnet.ibm.com>
References: <1386066977-17368-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
	<20131203143841.11b71e387dc1db3a8ab0974c@linux-foundation.org>
	<529EE811.5050306@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Cc: Fengguang Wu <fengguang.wu@intel.com>, David Cohen <david.a.cohen@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Damien Ramonda <damien.ramonda@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 04 Dec 2013 14:00:09 +0530 Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com> wrote:

> > I don't recall the rationale for the current code and of course we
> > didn't document it.  It might be in the changelogs somewhere - could
> > you please do the git digging and see if you can find out?
> 
> Unfaortunately, from my search, I saw that the code belonged to pre git
> time, so could not get much information on that.

Here: https://lkml.org/lkml/2004/8/20/242

It seems it was done as a rather thoughtless performance optimisation. 
I'd say it's time to reimplement max_sane_readahead() from scratch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
