Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0D2DD6B0006
	for <linux-mm@kvack.org>; Fri, 12 Oct 2018 16:59:52 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id r134-v6so5157621pgr.19
        for <linux-mm@kvack.org>; Fri, 12 Oct 2018 13:59:52 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id s16-v6si2186574plp.336.2018.10.12.13.59.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Oct 2018 13:59:51 -0700 (PDT)
Date: Fri, 12 Oct 2018 13:59:49 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v7 2/6] mm: export add_swap_extent()
Message-Id: <20181012135949.321223ab4adfd6d34093fdaa@linux-foundation.org>
In-Reply-To: <bb1208575e02829aae51b538709476964f97b1ea.1536704650.git.osandov@fb.com>
References: <cover.1536704650.git.osandov@fb.com>
	<bb1208575e02829aae51b538709476964f97b1ea.1536704650.git.osandov@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Omar Sandoval <osandov@osandov.com>
Cc: linux-btrfs@vger.kernel.org, kernel-team@fb.com, linux-mm@kvack.org

On Tue, 11 Sep 2018 15:34:45 -0700 Omar Sandoval <osandov@osandov.com> wrote:

> From: Omar Sandoval <osandov@fb.com>
> 
> Btrfs will need this for swap file support.
> 

Acked-by: Andrew Morton <akpm@linux-foundation.org>
