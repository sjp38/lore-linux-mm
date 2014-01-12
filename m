Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f173.google.com (mail-qc0-f173.google.com [209.85.216.173])
	by kanga.kvack.org (Postfix) with ESMTP id 6A3216B0031
	for <linux-mm@kvack.org>; Sat, 11 Jan 2014 22:39:07 -0500 (EST)
Received: by mail-qc0-f173.google.com with SMTP id i8so1844295qcq.18
        for <linux-mm@kvack.org>; Sat, 11 Jan 2014 19:39:07 -0800 (PST)
Received: from mail-qc0-x230.google.com (mail-qc0-x230.google.com [2607:f8b0:400d:c01::230])
        by mx.google.com with ESMTPS id n6si172144qcg.5.2014.01.11.19.39.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 11 Jan 2014 19:39:06 -0800 (PST)
Received: by mail-qc0-f176.google.com with SMTP id e16so3066545qcx.35
        for <linux-mm@kvack.org>; Sat, 11 Jan 2014 19:39:06 -0800 (PST)
Date: Sat, 11 Jan 2014 22:39:02 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC PATCHv3 03/11] percpu: use VMALLOC_TOTAL instead of
 VMALLOC_END - VMALLOC_START
Message-ID: <20140112033902.GC7874@mtj.dyndns.org>
References: <1388699609-18214-1-git-send-email-lauraa@codeaurora.org>
 <1388699609-18214-4-git-send-email-lauraa@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1388699609-18214-4-git-send-email-lauraa@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Kyungmin Park <kmpark@infradead.org>, Dave Hansen <dave@sr71.net>, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org

On Thu, Jan 02, 2014 at 01:53:21PM -0800, Laura Abbott wrote:
> vmalloc already gives a useful macro to calculate the total vmalloc
> size. Use it.
> 
> Signed-off-by: Laura Abbott <lauraa@codeaurora.org>

Applied to percpu/for-3.14.  Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
