Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 01B026B0044
	for <linux-mm@kvack.org>; Thu,  5 Nov 2009 21:13:58 -0500 (EST)
Date: Fri, 6 Nov 2009 10:13:55 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH v2 1/3] page-types: learn to describe flags directly
	from command line
Message-ID: <20091106021355.GB21057@localhost>
References: <20091105201846.25492.52935.stgit@bob.kio> <20091105202116.25492.28878.stgit@bob.kio>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091105202116.25492.28878.stgit@bob.kio>
Sender: owner-linux-mm@kvack.org
To: Alex Chiang <achiang@hp.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "Li, Haicheng" <haicheng.li@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, Nov 06, 2009 at 04:21:16AM +0800, Alex Chiang wrote:
> From: Wu Fengguang <fengguang.wu@intel.com>
> 
> Teach page-types to describe page flags directly from the command
> line.
> 
> Why is this useful? For instance, if you're using memory hotplug
> and see this in /var/log/messages:
> 
> 	kernel: removing from LRU failed 3836dd0/1/1e00000000000010
> 
> It would be nice to decode those page flags without staring at
> the source.
> 
> Example usage and output:
> 
> # Documentation/vm/page-types -d 0x10
> 0x0000000000000010	____D_____________________________	dirty
> 
> # Documentation/vm/page-types -d anon
> 0x0000000000001000	____________a_____________________	anonymous
> 
> # Documentation/vm/page-types -d anon,0x10
> 0x0000000000001010	____D_______a_____________________	dirty,anonymous

Good examples, thanks!

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>

> [achiang@hp.com: documentation]
> Cc: Andi Kleen <andi@firstfloor.org>
> Cc: Haicheng Li <haicheng.li@intel.com>
> Signed-off-by: Alex Chiang <achiang@hp.com>
> ---
> 
>  Documentation/vm/page-types.c |   21 ++++++++++++++++++++-
>  1 files changed, 20 insertions(+), 1 deletions(-)
> 
> diff --git a/Documentation/vm/page-types.c b/Documentation/vm/page-types.c
> index 3ec4f2a..a93c28e 100644
> --- a/Documentation/vm/page-types.c
> +++ b/Documentation/vm/page-types.c
> @@ -674,6 +674,7 @@ static void usage(void)
>  	printf(
>  "page-types [options]\n"
>  "            -r|--raw                  Raw mode, for kernel developers\n"
> +"            -d|--describe flags        Describe flags\n"

"Decode flags number; Encode flags name"?

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
