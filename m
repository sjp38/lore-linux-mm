Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 3163D6B0033
	for <linux-mm@kvack.org>; Mon, 29 Jul 2013 18:11:28 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id kx1so6115647pab.41
        for <linux-mm@kvack.org>; Mon, 29 Jul 2013 15:11:27 -0700 (PDT)
Date: Mon, 29 Jul 2013 15:11:25 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/2] mm: page_alloc: Add unlikely for MAX_ORDER check
In-Reply-To: <1375022906-1164-1-git-send-email-waydi1@gmail.com>
Message-ID: <alpine.DEB.2.02.1307291511020.29771@chino.kir.corp.google.com>
References: <1375022906-1164-1-git-send-email-waydi1@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: SeungHun Lee <waydi1@gmail.com>
Cc: linux-mm@kvack.org

On Sun, 28 Jul 2013, SeungHun Lee wrote:

> "order >= MAX_ORDER" case is occur rarely.
> 
> So I add unlikely for this check.

This needs your signed-off-by line.

When that's done:

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
