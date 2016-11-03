Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0AE35280250
	for <linux-mm@kvack.org>; Thu,  3 Nov 2016 13:26:26 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id x186so37114599vkd.1
        for <linux-mm@kvack.org>; Thu, 03 Nov 2016 10:26:26 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q42si1952398uaq.161.2016.11.03.10.26.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Nov 2016 10:26:25 -0700 (PDT)
Date: Thu, 3 Nov 2016 19:24:39 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH v3 1/3] fs/exec: don't force writing memory access
Message-ID: <20161103182439.GC11212@redhat.com>
References: <1478142286-18427-1-git-send-email-jann@thejh.net> <1478142286-18427-4-git-send-email-jann@thejh.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1478142286-18427-4-git-send-email-jann@thejh.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jann Horn <jann@thejh.net>
Cc: security@kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, Paul Moore <paul@paul-moore.com>, Stephen Smalley <sds@tycho.nsa.gov>, Eric Paris <eparis@parisplace.org>, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge@hallyn.com>, mchong@google.com, Andy Lutomirski <luto@amacapital.net>, Ingo Molnar <mingo@kernel.org>, Nick Kralevich <nnk@google.com>, Janis Danisevskis <jdanis@google.com>, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 11/03, Jann Horn wrote:
>
> This shouldn't change behavior in any way - at this point, there should be
> no non-writable mappings, only the initial stack mapping -,

So this FOLL_FORCE just adds the unnecessary confusion,

> but this change
> makes it easier to reason about the correctness of the following commits
> that place restrictions on forced memory writes.

and to me it looks like a good cleanup regardless. Exactly because it
is not clear why do we need FOLL_FORCE.

> Signed-off-by: Jann Horn <jann@thejh.net>
> Reviewed-by: Janis Danisevskis <jdanis@android.com>

Acked-by: Oleg Nesterov <oleg@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
