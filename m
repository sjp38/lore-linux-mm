Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id A2B3D6B02C0
	for <linux-mm@kvack.org>; Thu,  3 Nov 2016 17:14:06 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id ro13so28081266pac.7
        for <linux-mm@kvack.org>; Thu, 03 Nov 2016 14:14:06 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id bu5si7478266pab.140.2016.11.03.14.14.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Nov 2016 14:14:05 -0700 (PDT)
Date: Thu, 3 Nov 2016 14:14:04 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] z3fold: make pages_nr atomic
Message-Id: <20161103141404.2bb6b59435e560f0b82c0a18@linux-foundation.org>
In-Reply-To: <20161103220058.3017148c790b352c0ec521d4@gmail.com>
References: <20161103220058.3017148c790b352c0ec521d4@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitalywool@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, Dan Streetman <ddstreet@ieee.org>

On Thu, 3 Nov 2016 22:00:58 +0100 Vitaly Wool <vitalywool@gmail.com> wrote:

> This patch converts pages_nr per-pool counter to atomic64_t.

Which is slower.

Presumably there is a reason for making this change.  This reason
should be described in the changelog.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
