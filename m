Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id B6B416B0253
	for <linux-mm@kvack.org>; Tue, 17 May 2016 12:30:48 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id v128so41914698qkh.1
        for <linux-mm@kvack.org>; Tue, 17 May 2016 09:30:48 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f71si2745940qge.127.2016.05.17.09.30.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 May 2016 09:30:48 -0700 (PDT)
Date: Tue, 17 May 2016 18:30:44 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH v2 1/1] userfaultfd: don't pin the user memory in
 userfaultfd_file_create()
Message-ID: <20160517163044.GA31867@redhat.com>
References: <20160516152522.GA19120@redhat.com>
 <20160516152546.GA19129@redhat.com>
 <20160516172254.GA8595@redhat.com>
 <20160517153302.GE14446@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160517153302.GE14446@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 05/17, Michal Hocko wrote:
>
> On Mon 16-05-16 19:22:54, Oleg Nesterov wrote:
>
> > The patch adds the new trivial helper, mmget_not_zero(), it can have more users.
>
> Is this really helpful?

Well, this is subjective of course, but I think the code looks a bit better this
way. uprobes, fs/proc and more can use this helper too.

And in fact the initial version of this patch did atomic_inc_not_zero(mm->users) by
hand, then it was suggested to add a helper.

> > Signed-off-by: Oleg Nesterov <oleg@redhat.com>
>
> The patch seems good to me but I am not familiar with the userfaultfd
> internals enought to give you reviewed-by nor acked-by. I welcome the
> change anyway.

Thanks ;)

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
