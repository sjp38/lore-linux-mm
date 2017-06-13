Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id D65626B0314
	for <linux-mm@kvack.org>; Tue, 13 Jun 2017 03:55:31 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id 20so59018101qtq.2
        for <linux-mm@kvack.org>; Tue, 13 Jun 2017 00:55:31 -0700 (PDT)
Received: from mail-qt0-x22d.google.com (mail-qt0-x22d.google.com. [2607:f8b0:400d:c0d::22d])
        by mx.google.com with ESMTPS id o4si10832339qkf.1.2017.06.13.00.55.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Jun 2017 00:55:31 -0700 (PDT)
Received: by mail-qt0-x22d.google.com with SMTP id c10so159971929qtd.1
        for <linux-mm@kvack.org>; Tue, 13 Jun 2017 00:55:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1dccd8da-c96f-3947-d90f-a3f3d4f389fd@schaufler-ca.com>
References: <1497286620-15027-1-git-send-email-s.mesoraca16@gmail.com>
 <1497286620-15027-6-git-send-email-s.mesoraca16@gmail.com> <1dccd8da-c96f-3947-d90f-a3f3d4f389fd@schaufler-ca.com>
From: Salvatore Mesoraca <s.mesoraca16@gmail.com>
Date: Tue, 13 Jun 2017 09:55:30 +0200
Message-ID: <CAJHCu1LdGEEFkpAZqVYYORfXxTA+VuHUv2Pv+rYMN1Nt4KGVBg@mail.gmail.com>
Subject: Re: [PATCH 05/11] Creation of "check_vmflags" LSM hook
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Casey Schaufler <casey@schaufler-ca.com>
Cc: kernel list <linux-kernel@vger.kernel.org>, linux-security-module@vger.kernel.org, Kernel Hardening <kernel-hardening@lists.openwall.com>, Brad Spengler <spender@grsecurity.net>, PaX Team <pageexec@freemail.hu>, Kees Cook <keescook@chromium.org>, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge@hallyn.com>, linux-mm@kvack.org

2017-06-12 23:31 GMT+02:00 Casey Schaufler <casey@schaufler-ca.com>:
> Have the hook return a value and return that rather
> than -EPERM. That way a security module can choose an
> error that it determines is appropriate. It is possible
> that a module might want to deny the access for a reason
> other than lack of privilege.
> [...]
>
> Same here
>
> [...]
>
> And here.

Yes, I think you are right. I'll fix it in the next version.
Thank you very much for taking the time to review my patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
