Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6CFE16B0266
	for <linux-mm@kvack.org>; Tue,  2 Oct 2018 07:05:31 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id w18-v6so1531485plp.3
        for <linux-mm@kvack.org>; Tue, 02 Oct 2018 04:05:31 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id t64-v6si14054913pgd.8.2018.10.02.04.05.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Oct 2018 04:05:30 -0700 (PDT)
Date: Tue, 2 Oct 2018 14:05:24 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCHv3 5/6] tools/gup_benchmark: Add parameter for hugetlb
Message-ID: <20181002110524.ckgrlmx5k54rvawt@black.fi.intel.com>
References: <20180921223956.3485-1-keith.busch@intel.com>
 <20180921223956.3485-6-keith.busch@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180921223956.3485-6-keith.busch@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Keith Busch <keith.busch@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>

On Fri, Sep 21, 2018 at 10:39:55PM +0000, Keith Busch wrote:

-ENOMSG

> Cc: Kirill Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Dave Hansen <dave.hansen@intel.com>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Signed-off-by: Keith Busch <keith.busch@intel.com>
> ---
>  tools/testing/selftests/vm/gup_benchmark.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/tools/testing/selftests/vm/gup_benchmark.c b/tools/testing/selftests/vm/gup_benchmark.c
> index f2c99e2436f8..5d96e2b3d2f1 100644
> --- a/tools/testing/selftests/vm/gup_benchmark.c
> +++ b/tools/testing/selftests/vm/gup_benchmark.c
> @@ -38,7 +38,7 @@ int main(int argc, char **argv)
>  	char *file = NULL;
>  	char *p;
>  
> -	while ((opt = getopt(argc, argv, "m:r:n:f:tTLU")) != -1) {
> +	while ((opt = getopt(argc, argv, "m:r:n:f:tTLUH")) != -1) {
>  		switch (opt) {
>  		case 'm':
>  			size = atoi(optarg) * MB;
> @@ -64,6 +64,9 @@ int main(int argc, char **argv)
>  		case 'w':
>  			write = 1;
>  			break;
> +		case 'H':
> +			flags |= MAP_HUGETLB;
> +			break;
>  		case 'f':
>  			file = optarg;
>  			flags &= ~(MAP_PRIVATE | MAP_ANONYMOUS);
> -- 
> 2.14.4
> 

-- 
 Kirill A. Shutemov
