Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id A4AF36B0035
	for <linux-mm@kvack.org>; Sat, 29 Mar 2014 09:30:23 -0400 (EDT)
Received: by mail-qg0-f47.google.com with SMTP id 63so5517342qgz.6
        for <linux-mm@kvack.org>; Sat, 29 Mar 2014 06:30:23 -0700 (PDT)
Received: from mail-qg0-x234.google.com (mail-qg0-x234.google.com [2607:f8b0:400d:c04::234])
        by mx.google.com with ESMTPS id g2si3851651qab.153.2014.03.29.06.30.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 29 Mar 2014 06:30:23 -0700 (PDT)
Received: by mail-qg0-f52.google.com with SMTP id q107so2057787qgd.39
        for <linux-mm@kvack.org>; Sat, 29 Mar 2014 06:30:22 -0700 (PDT)
Date: Sat, 29 Mar 2014 09:30:18 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 1/2] mm/percpu.c: renew the max_contig if we merge the
 head and previous block
Message-ID: <20140329133018.GD5553@htj.dyndns.org>
References: <1396011321-19759-1-git-send-email-nasa4836@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1396011321-19759-1-git-send-email-nasa4836@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jianyu Zhan <nasa4836@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, cl@linux-foundation.org, linux-kernel@vger.kernel.org

On Fri, Mar 28, 2014 at 08:55:21PM +0800, Jianyu Zhan wrote:
> Hi, tj,
> I've reworked the patches on top of percpu/for-3.15.
> 
> During pcpu_alloc_area(), we might merge the current head with the
> previous block. Since we have calculated the max_contig using the
> size of previous block before we skip it, and now we update the size
> of previous block, so we should renew the max_contig.
> 
> Signed-off-by: Jianyu Zhan <nasa4836@gmail.com>

Applied to percpu/for-3.15.

Thanks!

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
