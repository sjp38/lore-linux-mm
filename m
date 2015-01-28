Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 3C8656B0032
	for <linux-mm@kvack.org>; Wed, 28 Jan 2015 01:11:01 -0500 (EST)
Received: by mail-pd0-f177.google.com with SMTP id y13so23636790pdi.8
        for <linux-mm@kvack.org>; Tue, 27 Jan 2015 22:11:01 -0800 (PST)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id im8si4303813pbc.229.2015.01.27.22.11.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 27 Jan 2015 22:11:00 -0800 (PST)
Received: by mail-pa0-f44.google.com with SMTP id rd3so23436373pab.3
        for <linux-mm@kvack.org>; Tue, 27 Jan 2015 22:11:00 -0800 (PST)
Date: Wed, 28 Jan 2015 15:10:57 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH 1/2] zram: free meta out of init_lock
Message-ID: <20150128061057.GB442@swordfish>
References: <20150128001526.GA25828@blaptop>
 <20150128002203.GB25828@blaptop>
 <20150128020759.GA343@swordfish>
 <20150128025707.GB32712@blaptop>
 <20150128035354.GA7790@swordfish>
 <20150128040757.GA577@swordfish>
 <20150128045028.GB577@swordfish>
 <20150128045855.GD32712@blaptop>
 <20150128053541.GE32712@blaptop>
 <20150128060732.GA442@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150128060732.GA442@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Jerome Marchand <jmarchan@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nitin Gupta <ngupta@vflare.org>

On (01/28/15 15:08), Sergey Senozhatsky wrote:
> hm... no, it's 100% stable

sorry, should be "it's NOT 100% stable".

	-ss

>  ./iozone -t 3 -R -r 16K -s 60M -I +Z
> 
>         test           base        srcu
> 
>  "  Initial write " 1274320.94  1251996.78
>  "        Rewrite " 1965783.94  1994964.06
>  "           Read " 4994070.75  4785895.88
>  "        Re-read " 5134244.62  5010810.50
>  "   Reverse Read " 4098531.38  4049988.38
>  "    Stride read " 4577775.75  4263884.50
>  "    Random read " 4131315.75  4636718.38
>  " Mixed workload " 3675635.25  3854783.06
>  "   Random write " 1832045.12  1863511.31
>  "         Pwrite " 1238366.59  1258660.47
>  "          Pread " 2475710.28  2404201.75
>  "         Fwrite " 2410579.94  2396443.25
>  "          Fread " 7723248.00  7127479.75
> 
>  "  Initial write " 1325167.41  1321517.41
>  "        Rewrite " 2044098.62  2161141.06
>  "           Read " 5267661.12  6203909.25
>  "        Re-read " 5458601.62  5773477.12
>  "   Reverse Read " 5001896.25  5103856.12
>  "    Stride read " 4858877.62  5003335.25
>  "    Random read " 4620529.88  4685374.62
>  " Mixed workload " 3868978.19  3939195.31
>  "   Random write " 2037816.75  1949729.56
>  "         Pwrite " 1298255.91  1323038.47
>  "          Pread " 2688768.09  2957903.06
>  "         Fwrite " 2482632.44  2351247.50
>  "          Fread " 7905214.75  7500859.75
> 
>  "  Initial write " 1334890.88  1332275.59
>  "        Rewrite " 2061126.00  2152643.69
>  "           Read " 5749209.88  5652791.62
>  "        Re-read " 5845869.00  6261777.25
>  "   Reverse Read " 4681375.12  4875618.50
>  "    Stride read " 4760689.75  5242670.00
>  "    Random read " 5112395.75  4650536.62
>  " Mixed workload " 4129292.06  4075847.88
>  "   Random write " 2067824.19  2022719.88
>  "         Pwrite " 1328648.88  1334709.97
>  "          Pread " 2607281.94  2581113.12
>  "         Fwrite " 2404771.38  2348427.62
>  "          Fread " 7903982.75  7486812.50
> 
> 	-ss
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
