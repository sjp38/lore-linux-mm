Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id B62BA6B3019
	for <linux-mm@kvack.org>; Fri, 24 Aug 2018 10:12:15 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id q3-v6so7803779qki.4
        for <linux-mm@kvack.org>; Fri, 24 Aug 2018 07:12:15 -0700 (PDT)
Received: from a9-54.smtp-out.amazonses.com (a9-54.smtp-out.amazonses.com. [54.240.9.54])
        by mx.google.com with ESMTPS id 19-v6si3631566qkp.201.2018.08.24.07.12.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 24 Aug 2018 07:12:14 -0700 (PDT)
Date: Fri, 24 Aug 2018 14:12:14 +0000
From: Christopher Lameter <cl@linux.com>
Subject: Re: [GIT PULL] XArray for 4.19
In-Reply-To: <0c8ffb97-5896-148c-bff8-ffb92a60b307@suse.cz>
Message-ID: <010001656c4742be-cbf4b700-bd19-46e4-ae10-fa24d39d244c-000000@email.amazonses.com>
References: <20180813161357.GB1199@bombadil.infradead.org> <0100016562b90938-02b97bb7-eddd-412d-8162-7519a70d4103-000000@email.amazonses.com> <0c8ffb97-5896-148c-bff8-ffb92a60b307@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Matthew Wilcox <willy@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, 24 Aug 2018, Vlastimil Babka wrote:

>
> I think you can just post those for review and say that they apply on
> top of xarray git? Maybe also with your own git URL with those applied
> for easier access? I'm curious but also sceptical that something so
> major would get picked up to mmotm immediately :)
>

I posted it awhile ago and was waiting for something definite to diff
against so that testing is simple.

The last release is at
https://www.spinics.net/lists/linux-mm/msg142496.html
