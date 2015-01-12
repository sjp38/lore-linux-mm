Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f41.google.com (mail-yh0-f41.google.com [209.85.213.41])
	by kanga.kvack.org (Postfix) with ESMTP id B4ED16B0075
	for <linux-mm@kvack.org>; Mon, 12 Jan 2015 18:10:06 -0500 (EST)
Received: by mail-yh0-f41.google.com with SMTP id a41so11053639yho.0
        for <linux-mm@kvack.org>; Mon, 12 Jan 2015 15:10:06 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id w16si9882230ykb.99.2015.01.12.15.10.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Jan 2015 15:10:05 -0800 (PST)
Date: Mon, 12 Jan 2015 15:10:04 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v12 10/20] dax: Replace XIP documentation with DAX
 documentation
Message-Id: <20150112151004.2080339a518ee43da95a6176@linux-foundation.org>
In-Reply-To: <1414185652-28663-11-git-send-email-matthew.r.wilcox@intel.com>
References: <1414185652-28663-1-git-send-email-matthew.r.wilcox@intel.com>
	<1414185652-28663-11-git-send-email-matthew.r.wilcox@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Matthew Wilcox <willy@linux.intel.com>

On Fri, 24 Oct 2014 17:20:42 -0400 Matthew Wilcox <matthew.r.wilcox@intel.com> wrote:

> Based on the original XIP documentation, this documents the current
> state of affairs, and includes instructions on how users can enable DAX
> if their devices and kernel support it.

Nice ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
