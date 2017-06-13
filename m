Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 51BCB6B02F3
	for <linux-mm@kvack.org>; Tue, 13 Jun 2017 03:53:01 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id o45so41366700qto.5
        for <linux-mm@kvack.org>; Tue, 13 Jun 2017 00:53:01 -0700 (PDT)
Received: from mail-qt0-x233.google.com (mail-qt0-x233.google.com. [2607:f8b0:400d:c0d::233])
        by mx.google.com with ESMTPS id e60si10729767qtb.235.2017.06.13.00.53.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Jun 2017 00:53:00 -0700 (PDT)
Received: by mail-qt0-x233.google.com with SMTP id u12so159938924qth.0
        for <linux-mm@kvack.org>; Tue, 13 Jun 2017 00:53:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170613063446.GA12537@infradead.org>
References: <1497286620-15027-1-git-send-email-s.mesoraca16@gmail.com>
 <1497286620-15027-6-git-send-email-s.mesoraca16@gmail.com> <20170613063446.GA12537@infradead.org>
From: Salvatore Mesoraca <s.mesoraca16@gmail.com>
Date: Tue, 13 Jun 2017 09:52:59 +0200
Message-ID: <CAJHCu1+R5bBzNGQ0Kjrk1S3y543wK_xVr2wzp7+DhazS=c12kQ@mail.gmail.com>
Subject: Re: [PATCH 05/11] Creation of "check_vmflags" LSM hook
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: kernel list <linux-kernel@vger.kernel.org>, linux-security-module@vger.kernel.org, Kernel Hardening <kernel-hardening@lists.openwall.com>, Brad Spengler <spender@grsecurity.net>, PaX Team <pageexec@freemail.hu>, Casey Schaufler <casey@schaufler-ca.com>, Kees Cook <keescook@chromium.org>, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge@hallyn.com>, linux-mm@kvack.org

2017-06-13 8:34 GMT+02:00 Christoph Hellwig <hch@infradead.org>:
> Please always post the whole series including the users, thanks.

I'm sorry for the inconvenience, it won't happen again.
Thank you for your comment.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
