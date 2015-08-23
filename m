Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f53.google.com (mail-oi0-f53.google.com [209.85.218.53])
	by kanga.kvack.org (Postfix) with ESMTP id 17AC86B0038
	for <linux-mm@kvack.org>; Sun, 23 Aug 2015 12:21:13 -0400 (EDT)
Received: by oiew67 with SMTP id w67so67380007oie.2
        for <linux-mm@kvack.org>; Sun, 23 Aug 2015 09:21:12 -0700 (PDT)
Received: from smtpbgau2.qq.com (smtpbgau2.qq.com. [54.206.34.216])
        by mx.google.com with ESMTPS id p18si10395520oem.32.2015.08.23.09.21.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 23 Aug 2015 09:21:11 -0700 (PDT)
From: gang.chen.5i5j@gmail.com
Subject: Re: [PATCH] mm: mmap: Simplify the failure return working flow
Date: Mon, 24 Aug 2015 00:20:53 +0800
Message-Id: <1440346853-17685-1-git-send-email-gang.chen.5i5j@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, kernel mailing list <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "riel@redhat.com" <riel@redhat.com>, "sasha.levin@oracle.com" <sasha.levin@oracle.com>, Linux Memory <linux-mm@kvack.org>

After trying, I guess, from = YOUR_GMAIL_ADDRESS

> 	envelopesender = YOUR_STABLE_SENDER_ADDRESS
> 	smtpserver = YOUR_STABLE_SMTP
> 
> [user] part will be used for s-o-b and Author email while the sendemail
> will be used for git send-email to route the patch properly. If the two
> differ it will add From: user.name <user.email> as suggested by Andrew.
> 

OK, thanks. I finished the configuration, and give a test (send and
receive test mail between my 2 mail address), it is OK.

I shall send patches in this way :-).

Thanks.
-- 
Chen Gang

Open, share, and attitude like air, water, and life which God blessed



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
