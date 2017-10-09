Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6A0486B0033
	for <linux-mm@kvack.org>; Mon,  9 Oct 2017 15:08:47 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id i63so17117339itc.18
        for <linux-mm@kvack.org>; Mon, 09 Oct 2017 12:08:47 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 32si5229169qtf.422.2017.10.09.12.08.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Oct 2017 12:08:46 -0700 (PDT)
Message-ID: <1507576124.21121.168.camel@redhat.com>
Subject: Re: [patch v2] madvise.2: Add MADV_WIPEONFORK documentation
From: Rik van Riel <riel@redhat.com>
Date: Mon, 09 Oct 2017 15:08:44 -0400
In-Reply-To: <CAKgNAkg8QJHfPfdfYXBU2-eW=_FWY99UYi_6hQejE=q5+66u1g@mail.gmail.com>
References: <20170914130040.6faabb18@cuia.usersys.redhat.com>
	 <CAAF6GDdnY2AmzKx+t4ffCFxJ+RZS++4tmWvoazdVNVSYjra_WA@mail.gmail.com>
	 <20170914150546.74ad3a9a@cuia.usersys.redhat.com>
	 <a1715d1d-7a03-d2db-7a8a-8a2edceae5d1@gmail.com>
	 <1505848907.5486.9.camel@redhat.com>
	 <CAKgNAkg8QJHfPfdfYXBU2-eW=_FWY99UYi_6hQejE=q5+66u1g@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mtk.manpages@gmail.com
Cc: Colm =?ISO-8859-1?Q?MacC=E1rthaigh?= <colm@allcosts.net>, linux-man <linux-man@vger.kernel.org>, lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>, nilal@redhat.com, Florian Weimer <fweimer@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>

On Mon, 2017-10-09 at 21:06 +0200, Michael Kerrisk (man-pages) wrote:
> Hi Rik,
> 
> I have a follow-up question re wipe-on-fork. What are the semantics
> for this setting with respect to fork() and exec()? That is, in the
> child of a fork(), does the flag remain set for the specified address
> range? (My quick read of the source suggests yes, but I have not
> tested.) And, when we do an exec(), my assumption is that the flag is
> cleared for the address range, but it would be good to have
> confirmation.

Indeed, on exec() the flag is cleared, because all
memory regions get replaced on exec().

The flag remains across a fork(), so if a child task
were to fork, the memory would be empty of contents
again in its child. This seems to most closely match
the use case of discarding things like cryptographic
secrets at fork time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
