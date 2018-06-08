Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id AE9F76B0005
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 20:59:57 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id 202-v6so298024itw.9
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 17:59:57 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id t2-v6si226460itt.75.2018.06.07.17.59.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 07 Jun 2018 17:59:56 -0700 (PDT)
Subject: Re: mmotm 2018-06-07-16-59 uploaded (fs/fat/ and fs/dax/)
References: <20180607235947.xWQtg%akpm@linux-foundation.org>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <7d9fbe5c-7865-dfd1-ce7a-7b2ceaa000fa@infradead.org>
Date: Thu, 7 Jun 2018 17:59:47 -0700
MIME-Version: 1.0
In-Reply-To: <20180607235947.xWQtg%akpm@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, broonie@kernel.org, mhocko@suse.cz, sfr@canb.auug.org.au, linux-next@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mm-commits@vger.kernel.org

On 06/07/2018 04:59 PM, akpm@linux-foundation.org wrote:
> The mm-of-the-moment snapshot 2018-06-07-16-59 has been uploaded to
> 
>    http://www.ozlabs.org/~akpm/mmotm/
> 

(on i386:)

../fs/fat/inode.c: In function '__fat_get_block':
../fs/fat/inode.c:162:3: warning: format '%ld' expects argument of type 'long int', but argument 5 has type 'sector_t' [-Wformat=]
   fat_fs_error(sb,
   ^


../fs/dax.c: In function 'dax_load_hole':
../fs/dax.c:1031:2: error: 'entry2' undeclared (first use in this function)
  entry2 = dax_insert_mapping_entry(mapping, vmf, entry, pfn,
  ^


Easy fixes... :)
-- 
~Randy
