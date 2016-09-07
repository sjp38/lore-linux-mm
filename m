Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id E5A8C6B0038
	for <linux-mm@kvack.org>; Wed,  7 Sep 2016 10:08:59 -0400 (EDT)
Received: by mail-yw0-f200.google.com with SMTP id f123so31328629ywd.2
        for <linux-mm@kvack.org>; Wed, 07 Sep 2016 07:08:59 -0700 (PDT)
Received: from mail.cybernetics.com (mail.cybernetics.com. [173.71.130.66])
        by mx.google.com with ESMTPS id s195si6303311ybs.258.2016.09.07.07.08.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 07 Sep 2016 07:08:59 -0700 (PDT)
Subject: Re: regression: lk 4.8 + !CONFIG_SHMEM + shmat() = oops
References: <58cdb20c-8195-ca05-3700-3ab37a031848@cybernetics.com>
 <20160907111452.GA138665@black.fi.intel.com>
From: Tony Battersby <tonyb@cybernetics.com>
Message-ID: <40022970-fe0d-a6e6-d9a1-2fc35573a5d4@cybernetics.com>
Date: Wed, 7 Sep 2016 10:08:52 -0400
MIME-Version: 1.0
In-Reply-To: <20160907111452.GA138665@black.fi.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, regressions@leemhuis.info

On 09/07/2016 07:14 AM, Kirill A. Shutemov wrote:
> Sorry, for delay. This should fix the issue:
>
> >From 9f8cc79361fc874f9926b476cc674b2604a35701 Mon Sep 17 00:00:00 2001
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Date: Wed, 7 Sep 2016 13:57:20 +0300
> Subject: [PATCH] ipc/shm: fix crash if CONFIG_SHMEM is not set
>

Thanks, that fixes it.

Tested-by: Tony Battersby <tonyb@cybernetics.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
