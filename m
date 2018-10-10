Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id C69D96B0010
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 18:45:45 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id b7-v6so4773331pgt.10
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 15:45:45 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id j20-v6si22681378pgh.535.2018.10.10.15.45.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Oct 2018 15:45:44 -0700 (PDT)
Date: Wed, 10 Oct 2018 16:42:42 -0600
From: Keith Busch <keith.busch@intel.com>
Subject: Re: [PATCH 4/6] tools/gup_benchmark: Allow user specified file
Message-ID: <20181010224242.GC11034@localhost.localdomain>
References: <20181010195605.10689-1-keith.busch@intel.com>
 <20181010195605.10689-4-keith.busch@intel.com>
 <20181010153101.4f5dcf6dcc01e71934eeb1ba@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181010153101.4f5dcf6dcc01e71934eeb1ba@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>

On Wed, Oct 10, 2018 at 03:31:01PM -0700, Andrew Morton wrote:
> On Wed, 10 Oct 2018 13:56:03 -0600 Keith Busch <keith.busch@intel.com> wrote:
> > +	filed = open(file, O_RDWR|O_CREAT);
> > +	if (filed < 0)
> > +		perror("open"), exit(filed);
> 
> Ick.  Like this, please:

Yeah, I agree. I just copied the style this file had been using in other
error cases, but I still find it less readable than your recommendation. 
 
> --- a/tools/testing/selftests/vm/gup_benchmark.c~tools-gup_benchmark-allow-user-specified-file-fix
> +++ a/tools/testing/selftests/vm/gup_benchmark.c
> @@ -71,8 +71,10 @@ int main(int argc, char **argv)
>  	}
>  
>  	filed = open(file, O_RDWR|O_CREAT);
> -	if (filed < 0)
> -		perror("open"), exit(filed);
> +	if (filed < 0) {
> +		perror("open");
> +		exit(filed);
> +	}
>  
>  	gup.nr_pages_per_call = nr_pages;
>  	gup.flags = write;
> 
