Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 8B70D6B0210
	for <linux-mm@kvack.org>; Fri, 14 May 2010 05:18:18 -0400 (EDT)
Received: from hpaq13.eem.corp.google.com (hpaq13.eem.corp.google.com [172.25.149.13])
	by smtp-out.google.com with ESMTP id o4E9I4R6025882
	for <linux-mm@kvack.org>; Fri, 14 May 2010 02:18:06 -0700
Received: from pwj7 (pwj7.prod.google.com [10.241.219.71])
	by hpaq13.eem.corp.google.com with ESMTP id o4E9I2HL006420
	for <linux-mm@kvack.org>; Fri, 14 May 2010 02:18:03 -0700
Received: by pwj7 with SMTP id 7so1155427pwj.16
        for <linux-mm@kvack.org>; Fri, 14 May 2010 02:18:01 -0700 (PDT)
Date: Fri, 14 May 2010 02:17:59 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/1] mm: add descriptive comment for TIF_MEMDIE
 declaration
In-Reply-To: <930863A4-0E91-4994-8EA0-E18361B0113D@dilger.ca>
Message-ID: <alpine.DEB.2.00.1005140217400.24388@chino.kir.corp.google.com>
References: <930863A4-0E91-4994-8EA0-E18361B0113D@dilger.ca>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andreas Dilger <adilger@dilger.ca>
Cc: linux-mm@kvack.org, "linux-kernel@vger.kernel.org Mailinglist" <linux-kernel@vger.kernel.org>, trivial@kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 13 May 2010, Andreas Dilger wrote:

> From: Andreas Dilger <adilger@dilger.ca>
> 
> Add descriptive comment for TIF_MEMDIE task flag declaration.
> 

It would probably be better to say functionally what it does: gives oom 
killed tasks access to memory reserves.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
