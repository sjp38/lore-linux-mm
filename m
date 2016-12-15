Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id CF9026B0253
	for <linux-mm@kvack.org>; Thu, 15 Dec 2016 14:07:26 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id b123so35409826itb.3
        for <linux-mm@kvack.org>; Thu, 15 Dec 2016 11:07:26 -0800 (PST)
Received: from resqmta-ch2-05v.sys.comcast.net (resqmta-ch2-05v.sys.comcast.net. [69.252.207.37])
        by mx.google.com with ESMTPS id i9si3171564itb.15.2016.12.15.11.07.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Dec 2016 11:07:26 -0800 (PST)
Date: Thu, 15 Dec 2016 13:06:23 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/2] bpf: do not use KMALLOC_SHIFT_MAX
In-Reply-To: <20161215164722.21586-2-mhocko@kernel.org>
Message-ID: <alpine.DEB.2.20.1612151305570.23471@east.gentwo.org>
References: <20161215164722.21586-1-mhocko@kernel.org> <20161215164722.21586-2-mhocko@kernel.org>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Alexei Starovoitov <ast@kernel.org>

On Thu, 15 Dec 2016, Michal Hocko wrote:

> 01b3f52157ff ("bpf: fix allocation warnings in bpf maps and integer
> overflow") has added checks for the maximum allocateable size. It
> (ab)used KMALLOC_SHIFT_MAX for that purpose. While this is not incorrect
> it is not very clean because we already have KMALLOC_MAX_SIZE for this
> very reason so let's change both checks to use KMALLOC_MAX_SIZE instead.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
