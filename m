Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id D292E6B4F37
	for <linux-mm@kvack.org>; Wed, 28 Nov 2018 17:11:30 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id o9so12970949pgv.19
        for <linux-mm@kvack.org>; Wed, 28 Nov 2018 14:11:30 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id u25si8039804pgm.532.2018.11.28.14.11.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Nov 2018 14:11:29 -0800 (PST)
Date: Wed, 28 Nov 2018 14:11:26 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH V2 0/5] NestMMU pte upgrade workaround for mprotect
Message-Id: <20181128141126.03004299897430353c37e889@linux-foundation.org>
In-Reply-To: <20181128143438.29458-1-aneesh.kumar@linux.ibm.com>
References: <20181128143438.29458-1-aneesh.kumar@linux.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: mpe@ellerman.id.au, benh@kernel.crashing.org, paulus@samba.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On Wed, 28 Nov 2018 20:04:33 +0530 "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com> wrote:

> We can upgrade pte access (R -> RW transition) via mprotect. We need
> to make sure we follow the recommended pte update sequence as outlined in
> commit: bd5050e38aec ("powerpc/mm/radix: Change pte relax sequence to handle nest MMU hang")
> for such updates. This patch series do that.

The mm bits look (mostly) OK to me.  I suggest all these be merged via
the appropriate powerpc tree.
