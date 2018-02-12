Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6B7046B002C
	for <linux-mm@kvack.org>; Mon, 12 Feb 2018 10:28:54 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id m19so1141637pgv.5
        for <linux-mm@kvack.org>; Mon, 12 Feb 2018 07:28:54 -0800 (PST)
Received: from ms.lwn.net (ms.lwn.net. [45.79.88.28])
        by mx.google.com with ESMTPS id n1-v6si5870495pld.589.2018.02.12.07.28.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Feb 2018 07:28:53 -0800 (PST)
Date: Mon, 12 Feb 2018 08:28:49 -0700
From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: [PATCH 5/6] Documentation for Pmalloc
Message-ID: <20180212082849.1377f7e6@lwn.net>
In-Reply-To: <20180210033714.GA12711@bombadil.infradead.org>
References: <20180130151446.24698-1-igor.stoppa@huawei.com>
	<20180130151446.24698-6-igor.stoppa@huawei.com>
	<20180130100852.2213b94d@lwn.net>
	<56eb3e0d-d74d-737a-9f85-fead2c40c17c@huawei.com>
	<20180210033714.GA12711@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Igor Stoppa <igor.stoppa@huawei.com>, jglisse@redhat.com, keescook@chromium.org, mhocko@kernel.org, labbott@redhat.com, hch@infradead.org, cl@linux.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

On Fri, 9 Feb 2018 19:37:14 -0800
Matthew Wilcox <willy@infradead.org> wrote:

> I've done this as the first line of my new documentation files:
> 
> .. SPDX-License-Identifier: CC-BY-SA-4.0
> 
> I think this is the CC license that's closest in spirit to the GPL without
> the unintended consequences of the GPL when used on documentation.  The
> GFDL seems to be out of favour these days.

I think that's a great license.  I still fear that it is not suitable for
kernel documentation, though, especially when we produce documents that
include significant text from the (GPL-licensed) kernel source.  The
result is almost certainly not distributable, and I don't think that's a
good thing.  The GPL is not perfect for documentation, but I don't think
that we have a better alternative for in-kernel docs.

jon

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
