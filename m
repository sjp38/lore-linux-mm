Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f53.google.com (mail-yh0-f53.google.com [209.85.213.53])
	by kanga.kvack.org (Postfix) with ESMTP id CCDB76B0031
	for <linux-mm@kvack.org>; Tue, 14 Jan 2014 20:31:39 -0500 (EST)
Received: by mail-yh0-f53.google.com with SMTP id b20so70361yha.40
        for <linux-mm@kvack.org>; Tue, 14 Jan 2014 17:31:39 -0800 (PST)
Received: from mail-yk0-x22c.google.com (mail-yk0-x22c.google.com [2607:f8b0:4002:c07::22c])
        by mx.google.com with ESMTPS id n2si2919240yho.283.2014.01.14.17.31.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 14 Jan 2014 17:31:38 -0800 (PST)
Received: by mail-yk0-f172.google.com with SMTP id 200so181977ykr.3
        for <linux-mm@kvack.org>; Tue, 14 Jan 2014 17:31:38 -0800 (PST)
Date: Tue, 14 Jan 2014 17:31:35 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC][PATCH v2 1/3] mm: Create utility function for accessing
 a tasks commandline value
In-Reply-To: <1389632555-7039-1-git-send-email-wroberts@tresys.com>
Message-ID: <alpine.DEB.2.02.1401141731210.32645@chino.kir.corp.google.com>
References: <1389632555-7039-1-git-send-email-wroberts@tresys.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: William Roberts <bill.c.roberts@gmail.com>
Cc: linux-audit@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rgb@redhat.com, viro@zeniv.linux.org.uk, akpm@linux-foundation.org, sds@tycho.nsa.gov, William Roberts <wroberts@tresys.com>

On Mon, 13 Jan 2014, William Roberts wrote:

> introduce get_cmdline() for retreiving the value of a processes
> proc/self/cmdline value.
> 
> Signed-off-by: William Roberts <wroberts@tresys.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
