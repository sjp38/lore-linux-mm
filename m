Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f169.google.com (mail-yk0-f169.google.com [209.85.160.169])
	by kanga.kvack.org (Postfix) with ESMTP id D3F456B0035
	for <linux-mm@kvack.org>; Tue, 14 Jan 2014 20:32:18 -0500 (EST)
Received: by mail-yk0-f169.google.com with SMTP id q9so182876ykb.0
        for <linux-mm@kvack.org>; Tue, 14 Jan 2014 17:32:18 -0800 (PST)
Received: from mail-yh0-x22f.google.com (mail-yh0-x22f.google.com [2607:f8b0:4002:c01::22f])
        by mx.google.com with ESMTPS id g70si2926381yhd.268.2014.01.14.17.32.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 14 Jan 2014 17:32:18 -0800 (PST)
Received: by mail-yh0-f47.google.com with SMTP id c41so359419yho.34
        for <linux-mm@kvack.org>; Tue, 14 Jan 2014 17:32:17 -0800 (PST)
Date: Tue, 14 Jan 2014 17:32:14 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC][PATCH v2 2/3] proc: Update get proc_pid_cmdline() to use
 mm.h helpers
In-Reply-To: <1389632555-7039-2-git-send-email-wroberts@tresys.com>
Message-ID: <alpine.DEB.2.02.1401141731560.32645@chino.kir.corp.google.com>
References: <1389632555-7039-1-git-send-email-wroberts@tresys.com> <1389632555-7039-2-git-send-email-wroberts@tresys.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: William Roberts <bill.c.roberts@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, rgb@redhat.com, viro@zeniv.linux.org.uk, Andrew Morton <akpm@linux-foundation.org>, sds@tycho.nsa.gov, William Roberts <wroberts@tresys.com>

On Mon, 13 Jan 2014, William Roberts wrote:

> Re-factor proc_pid_cmdline() to use get_cmdline() helper
> from mm.h.
> 
> Signed-off-by: William Roberts <wroberts@tresys.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
