Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f53.google.com (mail-qa0-f53.google.com [209.85.216.53])
	by kanga.kvack.org (Postfix) with ESMTP id BEF236B0037
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 16:34:11 -0400 (EDT)
Received: by mail-qa0-f53.google.com with SMTP id j15so2377253qaq.40
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 13:34:11 -0700 (PDT)
Received: from qmta11.emeryville.ca.mail.comcast.net (qmta11.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:211])
        by mx.google.com with ESMTP id l9si8058461qaa.85.2014.06.19.13.34.10
        for <linux-mm@kvack.org>;
        Thu, 19 Jun 2014 13:34:11 -0700 (PDT)
Date: Thu, 19 Jun 2014 15:34:08 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [patch] mm, slub: mark resiliency_test as init text
In-Reply-To: <alpine.DEB.2.02.1406171515390.32660@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.11.1406191533560.4002@gentwo.org>
References: <alpine.DEB.2.02.1406171515390.32660@chino.kir.corp.google.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org

On Tue, 17 Jun 2014, David Rientjes wrote:

> resiliency_test() is only called for bootstrap, so it may be moved to init.text
> and freed after boot.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
