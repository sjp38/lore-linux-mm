Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4AC486B025F
	for <linux-mm@kvack.org>; Mon,  6 Jun 2016 19:31:52 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id s139so170402276oie.0
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 16:31:52 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id 6si22107129ioh.72.2016.06.06.16.31.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Jun 2016 16:31:51 -0700 (PDT)
Date: Tue, 7 Jun 2016 09:31:17 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: undefined reference to `early_panic'
Message-ID: <20160607093117.541bed6a@canb.auug.org.au>
In-Reply-To: <20160606133120.cb13d4fa3b6bba4f5b427ca5@linux-foundation.org>
References: <201606051227.HWQZ0zJJ%fengguang.wu@intel.com>
	<20160606133120.cb13d4fa3b6bba4f5b427ca5@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild test robot <fengguang.wu@intel.com>, kbuild-all@01.org, linux-kernel@vger.kernel.org, Dan Williams <dan.j.williams@intel.com>, Linux Memory Management List <linux-mm@kvack.org>, Chris Metcalf <cmetcalf@mellanox.com>

Hi Andrew,

On Mon, 6 Jun 2016 13:31:20 -0700 Andrew Morton <akpm@linux-foundation.org> wrote:
>
> From: Andrew Morton <akpm@linux-foundation.org>
> Subject: tile: early_printk.o is always required

Added to linux-next today (will be dropped if it turns up elsewhere).

-- 
Cheers,
Stephen Rothwell

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
