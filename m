Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 790A16B0262
	for <linux-mm@kvack.org>; Fri, 22 May 2015 04:55:52 -0400 (EDT)
Received: by padbw4 with SMTP id bw4so14591586pad.0
        for <linux-mm@kvack.org>; Fri, 22 May 2015 01:55:52 -0700 (PDT)
Received: from mail-pd0-x233.google.com (mail-pd0-x233.google.com. [2607:f8b0:400e:c02::233])
        by mx.google.com with ESMTPS id zt10si2498700pac.63.2015.05.22.01.55.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 May 2015 01:55:51 -0700 (PDT)
Received: by pdbqa5 with SMTP id qa5so14673059pdb.0
        for <linux-mm@kvack.org>; Fri, 22 May 2015 01:55:51 -0700 (PDT)
Date: Fri, 22 May 2015 17:56:12 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] zram: check compressor name before setting it
Message-ID: <20150522085523.GA709@swordfish>
References: <1432283515-2005-1-git-send-email-m.jabrzyk@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1432283515-2005-1-git-send-email-m.jabrzyk@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marcin Jabrzyk <m.jabrzyk@samsung.com>
Cc: minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kyungmin.park@samsung.com

On (05/22/15 10:31), Marcin Jabrzyk wrote:
> Zram sysfs interface was not making any check of
> proper compressor name when setting it.
> Any name is accepted, but further tries of device
> creation would end up with not very meaningfull error.
> eg.
> 
> echo lz0 > comp_algorithm
> echo 200M > disksize
> echo: write error: Invalid argument
> 

no.

zram already complains about failed comp backend creation.
it's in dmesg (or syslog, etc.):

	"zram: Cannot initialise %s compressing backend"

second, there is not much value in exposing zcomp internals,
especially when the result is just another line in dmesg output.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
