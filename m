Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6C89B6B0033
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 12:45:08 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id b26so15417030qtb.18
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 09:45:08 -0800 (PST)
Received: from resqmta-ch2-01v.sys.comcast.net (resqmta-ch2-01v.sys.comcast.net. [2001:558:fe21:29:69:252:207:33])
        by mx.google.com with ESMTPS id d8si5631019qtm.189.2018.01.17.09.45.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jan 2018 09:45:07 -0800 (PST)
Date: Wed, 17 Jan 2018 11:42:34 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: kmem_cache_attr (was Re: [PATCH 04/36] usercopy: Prepare for
 usercopy whitelisting)
In-Reply-To: <20180116210313.GA7791@bombadil.infradead.org>
Message-ID: <alpine.DEB.2.20.1801171141430.23209@nuc-kabylake>
References: <1515531365-37423-1-git-send-email-keescook@chromium.org> <1515531365-37423-5-git-send-email-keescook@chromium.org> <alpine.DEB.2.20.1801101219390.7926@nuc-kabylake> <20180114230719.GB32027@bombadil.infradead.org> <alpine.DEB.2.20.1801160913260.3908@nuc-kabylake>
 <20180116160525.GF30073@bombadil.infradead.org> <alpine.DEB.2.20.1801161049320.5162@nuc-kabylake> <20180116174315.GA10461@bombadil.infradead.org> <alpine.DEB.2.20.1801161205590.1771@nuc-kabylake> <alpine.DEB.2.20.1801161215500.2945@nuc-kabylake>
 <20180116210313.GA7791@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Kees Cook <keescook@chromium.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Matthew Garrett <mjg59@google.com>, kernel-hardening@lists.openwall.com

On Tue, 16 Jan 2018, Matthew Wilcox wrote:

> struct kmem_cache_attr {
> 	char name[16];

That doesnt work. memcg needs long slab names. Sigh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
