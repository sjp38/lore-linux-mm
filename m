Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1EFDC6B0253
	for <linux-mm@kvack.org>; Thu, 29 Sep 2016 12:10:28 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id t63so3610462ywb.1
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 09:10:28 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o65si17143035ioe.219.2016.09.29.09.10.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Sep 2016 09:10:09 -0700 (PDT)
Date: Thu, 29 Sep 2016 18:09:01 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH v2 1/3] fs/exec: don't force writing memory access
Message-ID: <20160929160901.GB30031@redhat.com>
References: <1475103281-7989-1-git-send-email-jann@thejh.net> <1475103281-7989-2-git-send-email-jann@thejh.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1475103281-7989-2-git-send-email-jann@thejh.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jann Horn <jann@thejh.net>
Cc: security@kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, Paul Moore <paul@paul-moore.com>, Stephen Smalley <sds@tycho.nsa.gov>, Eric Paris <eparis@parisplace.org>, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge@hallyn.com>, Nick Kralevich <nnk@google.com>, Janis Danisevskis <jdanis@google.com>, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 09/29, Jann Horn wrote:
>
> @@ -204,7 +204,7 @@ static struct page *get_arg_page(struct linux_binprm *bprm, unsigned long pos,
>  	 * doing the exec and bprm->mm is the new process's mm.
>  	 */
>  	ret = get_user_pages_remote(current, bprm->mm, pos, 1, write,
> -			1, &page, NULL);
> +			0, &page, NULL);

To me this looks like a reasonable cleanup regardless, FOLL_FORCE
just adds the unnecessary confusion here.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
