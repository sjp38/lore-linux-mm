Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id C8A646B0253
	for <linux-mm@kvack.org>; Thu, 20 Aug 2015 03:45:25 -0400 (EDT)
Received: by wibhh20 with SMTP id hh20so28441454wib.0
        for <linux-mm@kvack.org>; Thu, 20 Aug 2015 00:45:25 -0700 (PDT)
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com. [209.85.212.177])
        by mx.google.com with ESMTPS id hw4si6918997wjb.135.2015.08.20.00.45.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Aug 2015 00:45:24 -0700 (PDT)
Received: by wibhh20 with SMTP id hh20so28440913wib.0
        for <linux-mm@kvack.org>; Thu, 20 Aug 2015 00:45:23 -0700 (PDT)
Date: Thu, 20 Aug 2015 09:45:21 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: mmap: Simplify the failure return working flow
Message-ID: <20150820074521.GC4780@dhcp22.suse.cz>
References: <55D5275D.7020406@hotmail.com>
 <COL130-W46B6A43FC26795B43939E0B9660@phx.gbl>
 <55D52CDE.8060700@hotmail.com>
 <COL130-W42D1358B7EBBCA5F39DA3CB9660@phx.gbl>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <COL130-W42D1358B7EBBCA5F39DA3CB9660@phx.gbl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gchen gchen <xili_gchen_5257@hotmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, kernel mailing list <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "riel@redhat.com" <riel@redhat.com>, "sasha.levin@oracle.com" <sasha.levin@oracle.com>, Linux Memory <linux-mm@kvack.org>

On Thu 20-08-15 09:27:42, gchen gchen wrote:
[...]
> Yes, it is really peculiar, the reason is gmail is not stable in China.
> I have to send mail in my hotmail address.
> 
> But I still want to use my gmail as Signed-off-by, since I have already
> used it, and also its name is a little formal than my hotmail.
> 
> Welcome any ideas, suggestions and completions for it (e.g. if it is
> necessary to let send mail and Signed-off-by mail be the same, I shall
> try).

You can do the following in your .git/config

[user]
	name = YOUR_NAME_FOR_S-O-B
	email = YOUR_GMAIL_ADDRESS
[sendemail]
	from = YOUR_STABLE_SENDER_ADDRESS
	envelopesender = YOUR_STABLE_SENDER_ADDRESS
	smtpserver = YOUR_STABLE_SMTP

[user] part will be used for s-o-b and Author email while the sendemail
will be used for git send-email to route the patch properly. If the two
differ it will add From: user.name <user.email> as suggested by Andrew.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
