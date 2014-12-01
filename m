Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 423476B0069
	for <linux-mm@kvack.org>; Mon,  1 Dec 2014 17:23:55 -0500 (EST)
Received: by mail-wg0-f49.google.com with SMTP id n12so7164410wgh.8
        for <linux-mm@kvack.org>; Mon, 01 Dec 2014 14:23:54 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id ly2si32184384wjb.126.2014.12.01.14.23.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Dec 2014 14:23:54 -0800 (PST)
Message-ID: <547CEA67.1090405@redhat.com>
Date: Mon, 01 Dec 2014 17:23:35 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 1/4] mm: Refactor do_wp_page, extract the reuse case
References: <1417467491-20071-1-git-send-email-raindel@mellanox.com> <1417467491-20071-2-git-send-email-raindel@mellanox.com>
In-Reply-To: <1417467491-20071-2-git-send-email-raindel@mellanox.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shachar Raindel <raindel@mellanox.com>, linux-mm@kvack.org
Cc: kirill.shutemov@linux.intel.com, mgorman@suse.de, ak@linux.intel.com, matthew.r.wilcox@intel.com, dave.hansen@linux.intel.com, n-horiguchi@ah.jp.nec.com, akpm@linux-foundation.org, torvalds@linux-foundation.org, haggaie@mellanox.com, aarcange@redhat.com, pfeiner@google.com, hannes@cmpxchg.org, sagig@mellanox.com, walken@google.com

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On 12/01/2014 03:58 PM, Shachar Raindel wrote:
> When do_wp_page is ending, in several cases it needs to reuse the 
> existing page. This is achieved by making the page table writable, 
> and possibly updating the page-cache state.
> 
> Currently, this logic was "called" by using a goto jump. This
> makes following the control flow of the function harder. It is
> also against the coding style guidelines for using goto.
> 
> As the code can easily be refactored into a specialized function, 
> refactor it out and simplify the code flow in do_wp_page.
> 
> Signed-off-by: Shachar Raindel <raindel@mellanox.com>

Acked-by: Rik van Riel <riel@redhat.com>


- -- 
All rights reversed
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJUfOpnAAoJEM553pKExN6DOB4H/iMUoIehI8cC+RF9mrwBlTg2
JUO7aH/Bgkgc/jSTWrFaBwjNPrrWuRQIKnQl/G48W9oLcj8njutH8lk6C8i337tK
PVhwmPZ+0cIZcSWJ7TCL2kFkovb4vA4pDnKGW78+QppjvoMRZRpuia4NVtRnmIp5
wuD7vKztZtfo4G10gnc09KfBYFZkWGn4NwJ+2cRei74K95anX0uXhq8cIOXf2fSJ
APDm+oZX8C/jdW7083k9yHPE46Ite2kZC9C6vLzv4kbHdH3D9lnT3mYkLUtyMeWh
a4pEJNnwAxkTdE5ghRUK+aqhMmq3k3VmAUo9QXcy7gNBZ7s02elruqIH6GjjE28=
=rVzj
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
