Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2DE7E6B0003
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 19:35:34 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id o7-v6so1986915pll.13
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 16:35:34 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 61-v6si4942094plr.483.2018.06.27.16.35.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jun 2018 16:35:33 -0700 (PDT)
Date: Wed, 27 Jun 2018 16:35:31 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: hugetlb: yield when prepping struct pages
Message-Id: <20180627163531.600a312b8f49088e3e4aa72f@linux-foundation.org>
In-Reply-To: <89c34814-ee1a-6339-1daf-fff02ce947e5@oracle.com>
References: <20180627214447.260804-1-cannonmatthews@google.com>
	<89c34814-ee1a-6339-1daf-fff02ce947e5@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Cannon Matthews <cannonmatthews@google.com>, Nadia Yvette Chambers <nyc@holomorphy.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, andreslc@google.com, pfeiner@google.com, gthelen@google.com

On Wed, 27 Jun 2018 16:27:24 -0700 Mike Kravetz <mike.kravetz@oracle.com> wrote:

> My only suggestion would be to remove the mention of 2M pages in the
> commit message.  Thanks for adding this.

I have removed that sentence.

> Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>

Thanks again.
