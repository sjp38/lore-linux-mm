Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 64EF26B0044
	for <linux-mm@kvack.org>; Thu,  5 Nov 2009 21:16:31 -0500 (EST)
Date: Fri, 6 Nov 2009 10:15:25 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH v2 3/3] page-types: exit early when invoked with
	-d|--describe
Message-ID: <20091106021525.GD21057@localhost>
References: <20091105201846.25492.52935.stgit@bob.kio> <20091105202126.25492.84269.stgit@bob.kio>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091105202126.25492.84269.stgit@bob.kio>
Sender: owner-linux-mm@kvack.org
To: Alex Chiang <achiang@hp.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "Li, Haicheng" <haicheng.li@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>


>  		case 'd':
> -			opt_no_summary = 1;
>  			describe_flags(optarg);
> -			break;
> +			exit(0);
>  		case 'l':
>  			opt_list = 1;
>  			break;
 
Good catch, thanks!

Acked-by: Wu Fengguang <fengguang.wu@intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
