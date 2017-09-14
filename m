Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 743B26B0033
	for <linux-mm@kvack.org>; Thu, 14 Sep 2017 15:10:32 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id t46so350215qtj.5
        for <linux-mm@kvack.org>; Thu, 14 Sep 2017 12:10:32 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id d198sor5399523qkg.135.2017.09.14.12.10.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 14 Sep 2017 12:10:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170914150546.74ad3a9a@cuia.usersys.redhat.com>
References: <20170914130040.6faabb18@cuia.usersys.redhat.com>
 <CAAF6GDdnY2AmzKx+t4ffCFxJ+RZS++4tmWvoazdVNVSYjra_WA@mail.gmail.com> <20170914150546.74ad3a9a@cuia.usersys.redhat.com>
From: =?UTF-8?Q?Colm_MacC=C3=A1rthaigh?= <colm@allcosts.net>
Date: Thu, 14 Sep 2017 12:10:30 -0700
Message-ID: <CAAF6GDfr8kJObk5qFqZg3cBDLVXZU0WzuLhsputoC8uSSiSdgw@mail.gmail.com>
Subject: Re: [patch v2] madvise.2: Add MADV_WIPEONFORK documentation
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Michael Kerrisk-manpages <mtk.manpages@gmail.com>, linux-man@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, nilal@redhat.com, Florian Weimer <fweimer@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>

On Thu, Sep 14, 2017 at 12:05 PM, Rik van Riel <riel@redhat.com> wrote:
> v2: implement the improvements suggested by Colm, and add
>     Colm's text to the fork.2 man page
>     (Colm, I have added a signed-off-by in your name - is that ok?)

Yep, that's ok! Whole thing LGTM.

-- 
Colm

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
