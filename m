Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id AE9BA6B0024
	for <linux-mm@kvack.org>; Tue, 27 Mar 2018 12:55:12 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id c65so5689861pfa.5
        for <linux-mm@kvack.org>; Tue, 27 Mar 2018 09:55:12 -0700 (PDT)
Received: from ms.lwn.net (ms.lwn.net. [45.79.88.28])
        by mx.google.com with ESMTPS id 4-v6si1693534pld.371.2018.03.27.09.55.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Mar 2018 09:55:11 -0700 (PDT)
Date: Tue, 27 Mar 2018 10:55:09 -0600
From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: [RFC PATCH v21 0/6] mm: security: ro protection for dynamic
 data
Message-ID: <20180327105509.62ec0d4d@lwn.net>
In-Reply-To: <20180327153742.17328-1-igor.stoppa@huawei.com>
References: <20180327153742.17328-1-igor.stoppa@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>
Cc: willy@infradead.org, keescook@chromium.org, mhocko@kernel.org, david@fromorbit.com, rppt@linux.vnet.ibm.com, labbott@redhat.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, igor.stoppa@gmail.com

On Tue, 27 Mar 2018 18:37:36 +0300
Igor Stoppa <igor.stoppa@huawei.com> wrote:

> This patch-set introduces the possibility of protecting memory that has
> been allocated dynamically.

One thing that jumps out at me as I look at the patch set is: you do not
include any users of this functionality.  Where do you expect this
allocator to be used?  Actually seeing the API in action would be a useful
addition, I think.

Thanks,

jon
