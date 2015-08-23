Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id DD1936B0254
	for <linux-mm@kvack.org>; Sun, 23 Aug 2015 12:28:50 -0400 (EDT)
Received: by pdrh1 with SMTP id h1so44796239pdr.0
        for <linux-mm@kvack.org>; Sun, 23 Aug 2015 09:28:50 -0700 (PDT)
Received: from smtpbg63.qq.com (smtpbg63.qq.com. [103.7.29.150])
        by mx.google.com with ESMTPS id pk3si23042955pdb.160.2015.08.23.09.28.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 23 Aug 2015 09:28:50 -0700 (PDT)
From: gang.chen.5i5j@gmail.com
Subject: Re: [PATCH] mm: mmap: Simplify the failure return working flow
Date: Mon, 24 Aug 2015 00:28:30 +0800
Message-Id: <1440347310-17925-1-git-send-email-gang.chen.5i5j@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: gang.chen.5i5j@qq.com, Chen Gang <gang.chen.5i5j@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, kernel mailing list <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "riel@redhat.com" <riel@redhat.com>, "sasha.levin@oracle.com" <sasha.levin@oracle.com>, Linux Memory <linux-mm@kvack.org>

On 8/20/15 15:45, Michal Hocko wrote:
> On Thu 20-08-15 09:27:42, gchen gchen wrote:
> [...]
>> Yes, it is really peculiar, the reason is gmail is not stable in China.
>> I have to send mail in my hotmail address.
>>
>> But I still want to use my gmail as Signed-off-by, since I have already
>> used it, and also its name is a little formal than my hotmail.
>>
>> Welcome any ideas, suggestions and completions for it (e.g. if it is
>> necessary to let send mail and Signed-off-by mail be the same, I shall
>> try).
> 
> You can do the following in your .git/config
> 
> [user]
> 	name = YOUR_NAME_FOR_S-O-B
> 	email = YOUR_GMAIL_ADDRESS
> [sendemail]
> 	from = YOUR_STABLE_SENDER_ADDRESS

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
