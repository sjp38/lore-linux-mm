Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f182.google.com (mail-pf0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 54F236B0009
	for <linux-mm@kvack.org>; Sat, 30 Jan 2016 21:15:12 -0500 (EST)
Received: by mail-pf0-f182.google.com with SMTP id x125so63675200pfb.0
        for <linux-mm@kvack.org>; Sat, 30 Jan 2016 18:15:12 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id vo4si13219471pab.143.2016.01.30.18.15.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 30 Jan 2016 18:15:10 -0800 (PST)
Date: Sun, 31 Jan 2016 13:15:06 +1100
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [slab] a1fd55538c: WARNING: CPU: 0 PID: 0 at
 kernel/locking/lockdep.c:2601 trace_hardirqs_on_caller()
Message-ID: <20160131131506.4aad01b5@canb.auug.org.au>
In-Reply-To: <20160130184646.6ea9c5f8@redhat.com>
References: <56aa2b47.MwdlkrzZ08oDKqh8%fengguang.wu@intel.com>
	<20160128184749.7bdee246@redhat.com>
	<21684.1454137770@turing-police.cc.vt.edu>
	<20160130184646.6ea9c5f8@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Valdis.Kletnieks@vt.edu, kernel test robot <fengguang.wu@intel.com>, LKP <lkp@01.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, wfg@linux.intel.com, Christoph Lameter <cl@linux.com>, Tejun Heo <tj@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Hi Jesper,

On Sat, 30 Jan 2016 18:46:46 +0100 Jesper Dangaard Brouer <brouer@redhat.com> wrote:
>
> Let me know, if the linux-next tree need's an explicit fix?

It would be a good idea if you could send a fix against linux-next to
me as Andrew is currently travelling.

-- 
Cheers,
Stephen Rothwell

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
