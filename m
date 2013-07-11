Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 8DDB96B0096
	for <linux-mm@kvack.org>; Thu, 11 Jul 2013 18:15:09 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id rl6so8377465pac.1
        for <linux-mm@kvack.org>; Thu, 11 Jul 2013 15:15:08 -0700 (PDT)
Date: Thu, 11 Jul 2013 15:15:06 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] madvise: fix checkpatch errors
In-Reply-To: <1373526037-9134-1-git-send-email-gg.kaspersky@gmail.com>
Message-ID: <alpine.DEB.2.02.1307111514560.2458@chino.kir.corp.google.com>
References: <1373526037-9134-1-git-send-email-gg.kaspersky@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Cernov <gg.kaspersky@gmail.com>
Cc: akpm@linux-foundation.org, sasha.levin@oracle.com, linux@rasmusvillemoes.dk, shli@fusionio.com, khlebnikov@openvz.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 11 Jul 2013, Vladimir Cernov wrote:

> This fixes following errors:
> 	- ERROR: "(foo*)" should be "(foo *)"
> 	- ERROR: "foo ** bar" should be "foo **bar"
> 
> Signed-off-by: Vladimir Cernov <gg.kaspersky@gmail.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
