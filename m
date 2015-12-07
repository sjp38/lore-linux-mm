Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 6D2BE6B025B
	for <linux-mm@kvack.org>; Mon,  7 Dec 2015 16:24:25 -0500 (EST)
Received: by wmvv187 with SMTP id v187so186402963wmv.1
        for <linux-mm@kvack.org>; Mon, 07 Dec 2015 13:24:25 -0800 (PST)
Received: from thejh.net (thejh.net. [37.221.195.125])
        by mx.google.com with ESMTP id lx4si38909808wjb.35.2015.12.07.13.24.24
        for <linux-mm@kvack.org>;
        Mon, 07 Dec 2015 13:24:24 -0800 (PST)
From: Jann Horn <jann@thejh.net>
Subject: Re: [PATCH] ptrace: use fsuid, fsgid, effective creds for fs access checks
Date: Mon,  7 Dec 2015 22:25:10 +0100
Message-Id: <1449523512-29200-1-git-send-email-jann@thejh.net>
In-Reply-To: <20151207203824.GA27364@pc.thejh.net>
References: <20151207203824.GA27364@pc.thejh.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Kees Cook <keescook@google.com>, Casey Schaufler <casey@schaufler-ca.com>
Cc: Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@redhat.com>, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge.hallyn@ubuntu.com>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, "Eric W. Biederman" <ebiederm@xmission.com>, Joe Perches <joe@perches.com>, Thomas Gleixner <tglx@linutronix.de>, Michael Kerrisk <mtk.manpages@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-security-module@vger.kernel.org, linux-api@vger.kernel.org, security@kernel.org, Willy Tarreau <w@1wt.eu>

Whoops. After Kees pointed out my last mistake, I decided to grep around a bit to make sure
I didn't miss anything else and noticed that apparently, Yama and Smack aren't completely
aware that the ptrace access mode can have flags ORed in? Until now, it was just the
NOAUDIT flag for /proc/$pid/stat, but with my patch, that would have been broken completely
as far as I can tell. I don't use either of those LSMs and didn't test with them.

Can the LSM maintainers have a look at this and say whether this looks okay now?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
