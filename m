Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id 28D85680DD3
	for <linux-mm@kvack.org>; Fri, 25 Dec 2015 19:05:11 -0500 (EST)
Received: by mail-ig0-f173.google.com with SMTP id ph11so117030108igc.1
        for <linux-mm@kvack.org>; Fri, 25 Dec 2015 16:05:11 -0800 (PST)
Received: from smtprelay.hostedemail.com (smtprelay0245.hostedemail.com. [216.40.44.245])
        by mx.google.com with ESMTPS id 128si20026057iof.186.2015.12.25.16.05.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Dec 2015 16:05:10 -0800 (PST)
Message-ID: <1451088307.12498.3.camel@perches.com>
Subject: Re: [PATCH v2 15/16] checkpatch: Add warning on deprecated
 walk_iomem_res
From: Joe Perches <joe@perches.com>
Date: Fri, 25 Dec 2015 16:05:07 -0800
In-Reply-To: <1451081365-15190-15-git-send-email-toshi.kani@hpe.com>
References: <1451081365-15190-1-git-send-email-toshi.kani@hpe.com>
	 <1451081365-15190-15-git-send-email-toshi.kani@hpe.com>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hpe.com>, akpm@linux-foundation.org, bp@alien8.de
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andy Whitcroft <apw@canonical.com>

On Fri, 2015-12-25 at 15:09 -0700, Toshi Kani wrote:
> Use of walk_iomem_res() is deprecated in new code.  Change
> checkpatch.pl to check new use of walk_iomem_res() and suggest
> to use walk_iomem_res_desc() instead.
[]
> diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
[]
> @@ -3424,6 +3424,12 @@ sub process {
>  			}
>  		}
>  
> +# check for uses of walk_iomem_res()
> +		if ($line =~ /\bwalk_iomem_res\(/) {
> +			WARN("walk_iomem_res",
> +			     "Use of walk_iomem_res is deprecated, please use walk_iomem_res_desc instead\n" . $herecurr)
> +		}
> +
>  # check for new typedefs, only function parameters and sparse annotations
>  # make sense.
>  		if ($line =~ /\btypedef\s/ &&

There are 6 uses of this function in the entire kernel tree.
Why not just change them, remove the function and avoid this?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
