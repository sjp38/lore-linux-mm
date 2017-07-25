Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id A2C4C6B025F
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 09:36:08 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id l81so13705701wmg.8
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 06:36:08 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h3si2159341wmd.176.2017.07.25.06.36.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 25 Jul 2017 06:36:06 -0700 (PDT)
Date: Tue, 25 Jul 2017 15:36:04 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH V2] selftests/vm: Add tests to validate mirror
 functionality with mremap
Message-ID: <20170725133604.GA27322@dhcp22.suse.cz>
References: <20170725063657.3915-1-khandual@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170725063657.3915-1-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mike.kravetz@oracle.com

On Tue 25-07-17 12:06:57, Anshuman Khandual wrote:
[...]
> diff --git a/tools/testing/selftests/vm/mremap_mirror_private_anon.c b/tools/testing/selftests/vm/mremap_mirror_private_anon.c
[...]
> +	ptr = mmap(NULL, alloc_size, PROT_READ | PROT_WRITE,
> +			MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
> +	if (ptr == MAP_FAILED) {
> +		perror("map() failed");
> +		return -1;
> +	}
> +	memset(ptr, PATTERN, alloc_size);
> +
> +	mirror_ptr =  (char *) mremap(ptr, 0, alloc_size, MREMAP_MAYMOVE);
> +	if (mirror_ptr == MAP_FAILED) {
> +		perror("mremap() failed");
> +		return -1;
> +	}

What is the point of this test? It will break with Mike's patch very
soon. Btw. it never worked. 
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
