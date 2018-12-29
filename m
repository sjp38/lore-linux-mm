Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8F4B68E005B
	for <linux-mm@kvack.org>; Sat, 29 Dec 2018 16:03:54 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id v11so20407964ply.4
        for <linux-mm@kvack.org>; Sat, 29 Dec 2018 13:03:54 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id g10si39447099plq.371.2018.12.29.13.03.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 29 Dec 2018 13:03:53 -0800 (PST)
Date: Sat, 29 Dec 2018 13:03:52 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] percpu: plumb gfp flag to pcpu_get_pages
Message-Id: <20181229130352.8a1075da5b7583d5e0e4aa9a@linux-foundation.org>
In-Reply-To: <20181229013147.211079-1-shakeelb@google.com>
References: <20181229013147.211079-1-shakeelb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Tejun Heo <tj@kernel.org>, Dennis Zhou <dennis@kernel.org>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 28 Dec 2018 17:31:47 -0800 Shakeel Butt <shakeelb@google.com> wrote:

> __alloc_percpu_gfp() can be called from atomic context, so, make
> pcpu_get_pages use the gfp provided to the higher layer.

Does this fix any user-visible issues?
