Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id DAE676B002D
	for <linux-mm@kvack.org>; Tue, 15 Nov 2011 13:16:39 -0500 (EST)
Date: Tue, 15 Nov 2011 19:16:34 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [patch v2 1/4]thp: improve the error code path
Message-ID: <20111115181634.GH4414@redhat.com>
References: <1321340651.22361.294.camel@sli10-conroe>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1321340651.22361.294.camel@sli10-conroe>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-mm <linux-mm@kvack.org>

On Tue, Nov 15, 2011 at 03:04:11PM +0800, Shaohua Li wrote:
> Improve the error code path. Delete unnecessary sysfs file for example.
> Also remove the #ifdef xxx to make code better.
> 
> Signed-off-by: Shaohua Li <shaohua.li@intel.com>

Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
