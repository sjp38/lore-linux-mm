Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 0B4566B0032
	for <linux-mm@kvack.org>; Fri, 23 Jan 2015 17:57:36 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id ey11so49690pad.7
        for <linux-mm@kvack.org>; Fri, 23 Jan 2015 14:57:35 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id be6si3497224pbd.160.2015.01.23.14.57.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Jan 2015 14:57:35 -0800 (PST)
Date: Fri, 23 Jan 2015 14:57:34 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC 0/3] Slab allocator array operations
Message-Id: <20150123145734.aa3c6c6e7432bc3534f2c4cc@linux-foundation.org>
In-Reply-To: <20150123213727.142554068@linux.com>
References: <20150123213727.142554068@linux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, penberg@kernel.org, iamjoonsoo@lge.com, Jesper Dangaard Brouer <brouer@redhat.com>

On Fri, 23 Jan 2015 15:37:27 -0600 Christoph Lameter <cl@linux.com> wrote:

> Attached a series of 3 patches to implement functionality to allocate
> arrays of pointers to slab objects. This can be used by the slab
> allocators to offer more optimized allocation and free paths.

What's the driver for this?  The networking people, I think?  If so,
some discussion about that would be useful: who is involved, why they
have this need, who are the people we need to bug to get it tested,
whether this implementation is found adequate, etc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
