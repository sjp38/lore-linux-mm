Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id C8ACC6B0038
	for <linux-mm@kvack.org>; Tue, 17 Oct 2017 19:28:20 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id c202so3036947oih.8
        for <linux-mm@kvack.org>; Tue, 17 Oct 2017 16:28:20 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id u83si1418413wmu.6.2017.10.17.16.28.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Oct 2017 16:28:19 -0700 (PDT)
Date: Tue, 17 Oct 2017 16:28:16 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/2] mm, thp: introduce dedicated transparent huge page
 allocation interfaces
Message-Id: <20171017162816.c5751bda5d51d3bf560b8503@linux-foundation.org>
In-Reply-To: <1508145557-9944-1-git-send-email-changbin.du@intel.com>
References: <1508145557-9944-1-git-send-email-changbin.du@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: changbin.du@intel.com
Cc: corbet@lwn.net, hughd@google.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 16 Oct 2017 17:19:15 +0800 changbin.du@intel.com wrote:

> The first one introduce new interfaces, the second one kills naming confusion.
> The aim is to remove duplicated code and simplify transparent huge page
> allocation.

These introduce various allnoconfig build errors.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
