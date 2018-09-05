Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8C3CE6B7404
	for <linux-mm@kvack.org>; Wed,  5 Sep 2018 13:04:51 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id 2-v6so4079523plc.11
        for <linux-mm@kvack.org>; Wed, 05 Sep 2018 10:04:51 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 4-v6si2526560pgp.645.2018.09.05.10.04.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Sep 2018 10:04:50 -0700 (PDT)
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id B0DCD20873
	for <linux-mm@kvack.org>; Wed,  5 Sep 2018 17:04:49 +0000 (UTC)
Received: by mail-wm0-f52.google.com with SMTP id q8-v6so8535808wmq.4
        for <linux-mm@kvack.org>; Wed, 05 Sep 2018 10:04:49 -0700 (PDT)
MIME-Version: 1.0
References: <1536163184-26356-1-git-send-email-rppt@linux.vnet.ibm.com> <1536163184-26356-8-git-send-email-rppt@linux.vnet.ibm.com>
In-Reply-To: <1536163184-26356-8-git-send-email-rppt@linux.vnet.ibm.com>
From: Rob Herring <robh@kernel.org>
Date: Wed, 5 Sep 2018 12:04:36 -0500
Message-ID: <CABGGiswdb1x-=vqrgxZ9i2dnLdsgtXq4+5H9Y1JRd90YVMW69A@mail.gmail.com>
Subject: Re: [RFC PATCH 07/29] memblock: remove _virt from APIs returning
 virtual address
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rppt@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, davem@davemloft.net, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, mingo@redhat.com, Michael Ellerman <mpe@ellerman.id.au>, mhocko@suse.com, paul.burton@mips.com, Thomas Gleixner <tglx@linutronix.de>, tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Wed, Sep 5, 2018 at 11:00 AM Mike Rapoport <rppt@linux.vnet.ibm.com> wrote:
>
> The conversion is done using
>
> sed -i 's@memblock_virt_alloc@memblock_alloc@g' \
>         $(git grep -l memblock_virt_alloc)

What's the reason to do this? It seems like a lot of churn even if a
mechanical change.

Rob
