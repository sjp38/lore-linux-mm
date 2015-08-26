Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f181.google.com (mail-lb0-f181.google.com [209.85.217.181])
	by kanga.kvack.org (Postfix) with ESMTP id 8475C6B0253
	for <linux-mm@kvack.org>; Wed, 26 Aug 2015 06:12:12 -0400 (EDT)
Received: by lbbpu9 with SMTP id pu9so116907683lbb.3
        for <linux-mm@kvack.org>; Wed, 26 Aug 2015 03:12:11 -0700 (PDT)
Received: from mail-la0-x22f.google.com (mail-la0-x22f.google.com. [2a00:1450:4010:c03::22f])
        by mx.google.com with ESMTPS id lm12si16894155lac.61.2015.08.26.03.12.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Aug 2015 03:12:10 -0700 (PDT)
Received: by lalv9 with SMTP id v9so115813051lal.0
        for <linux-mm@kvack.org>; Wed, 26 Aug 2015 03:12:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150826092302.GB3871@quack.suse.cz>
References: <1440489263-3547-1-git-send-email-kuleshovmail@gmail.com>
 <20150825140858.8185db77fed42cf5df5faeb5@linux-foundation.org> <20150826092302.GB3871@quack.suse.cz>
From: Alexander Kuleshov <kuleshovmail@gmail.com>
Date: Wed, 26 Aug 2015 16:11:50 +0600
Message-ID: <CANCZXo7F=ayRUqUq5QH71cMJezuQKvYQPNYgJ1buunBOuv1M6g@mail.gmail.com>
Subject: Re: [PATCH] mm/backing-dev: Check return value of the debugfs_create_dir()
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hello Jan,

2015-08-26 15:23 GMT+06:00 Jan Kara <jack@suse.cz>:
> Well, handling debugfs failures like in this patch is the right way to go,
> isn't it? Or what else would you imagine than checking for errors and
> bailing out instead of trying to create entries in non-existent dirs?

I think Andrew talks about this thread https://lkml.org/lkml/2015/8/14/555

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
