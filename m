Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 888076B0253
	for <linux-mm@kvack.org>; Wed,  7 Sep 2016 19:14:30 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id w78so69114354oie.0
        for <linux-mm@kvack.org>; Wed, 07 Sep 2016 16:14:30 -0700 (PDT)
Received: from mail.cybernetics.com (mail.cybernetics.com. [173.71.130.66])
        by mx.google.com with ESMTPS id n6si26140893oig.91.2016.09.07.11.57.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 07 Sep 2016 11:57:28 -0700 (PDT)
Subject: Re: [PATCH] ipc/shm: fix crash if CONFIG_SHMEM is not set
References: <20160907111452.GA138665@black.fi.intel.com>
 <201609072221.M7OSrgbL%fengguang.wu@intel.com>
 <20160907163303.GA99854@black.fi.intel.com>
From: Tony Battersby <tonyb@cybernetics.com>
Message-ID: <e4c48a7e-f41c-e6ee-31fb-53110a2e8151@cybernetics.com>
Date: Wed, 7 Sep 2016 14:57:24 -0400
MIME-Version: 1.0
In-Reply-To: <20160907163303.GA99854@black.fi.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org

On 09/07/2016 12:33 PM, Kirill A. Shutemov wrote:
>
> Urghh... no-MMU..
>
> This should work for them too.
>
> >From ad99dd548250fede88737ac0b0009e9a0e283b07 Mon Sep 17 00:00:00 2001
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Date: Wed, 7 Sep 2016 13:57:20 +0300
> Subject: [PATCH] ipc/shm: fix crash if CONFIG_SHMEM is not set
>

This one also works for me.

Tested-by: Tony Battersby <tonyb@cybernetics.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
