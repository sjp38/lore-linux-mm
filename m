Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f174.google.com (mail-qk0-f174.google.com [209.85.220.174])
	by kanga.kvack.org (Postfix) with ESMTP id 0CB116B007E
	for <linux-mm@kvack.org>; Sun, 27 Mar 2016 16:33:06 -0400 (EDT)
Received: by mail-qk0-f174.google.com with SMTP id x64so47421423qkd.1
        for <linux-mm@kvack.org>; Sun, 27 Mar 2016 13:33:06 -0700 (PDT)
Received: from ns.horizon.com (ns.horizon.com. [71.41.210.147])
        by mx.google.com with SMTP id b185si6143346ywf.400.2016.03.27.13.33.05
        for <linux-mm@kvack.org>;
        Sun, 27 Mar 2016 13:33:05 -0700 (PDT)
Date: 27 Mar 2016 16:33:04 -0400
Message-ID: <20160327203304.9695.qmail@ns.horizon.com>
From: "George Spelvin" <linux@horizon.com>
Subject: Re: Bloat caused by unnecessary calls to compound_head()?
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ebiggers3@gmail.com
Cc: kirill@shutemov.name, linux@horizon.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Could you just mark compound_head __pure?  That would tell the compiler
that it's safe to re-use the return value as long as there is no memory
mutation in between.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
