Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 97D216B0007
	for <linux-mm@kvack.org>; Sun, 27 Jan 2013 17:10:15 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id bi1so1152999pad.36
        for <linux-mm@kvack.org>; Sun, 27 Jan 2013 14:10:14 -0800 (PST)
Date: Sun, 27 Jan 2013 14:10:16 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 5/11] ksm: get_ksm_page locked
In-Reply-To: <1359254927.4159.11.camel@kernel>
Message-ID: <alpine.LNX.2.00.1301271408100.17144@eggly.anvils>
References: <alpine.LNX.2.00.1301251747590.29196@eggly.anvils> <alpine.LNX.2.00.1301251759470.29196@eggly.anvils> <1359254927.4159.11.camel@kernel>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Petr Holasek <pholasek@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <izik.eidus@ravellosystems.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, 26 Jan 2013, Simon Jeons wrote:
> 
> BTW, what's the meaning of ksm page forked? 

A ksm page is mapped into a process's mm, then that process calls fork():
the ksm page then appears in the child's mm, before ksmd has tracked it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
