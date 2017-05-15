Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1401C6B02EE
	for <linux-mm@kvack.org>; Mon, 15 May 2017 05:00:38 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id l73so41509456pfj.8
        for <linux-mm@kvack.org>; Mon, 15 May 2017 02:00:38 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id d185si10368583pgc.362.2017.05.15.02.00.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 May 2017 02:00:37 -0700 (PDT)
Date: Mon, 15 May 2017 11:00:27 +0200
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: Low memory killer problem
Message-ID: <20170515090027.GA18167@kroah.com>
References: <AF7C0ADF1FEABA4DABABB97411952A2EDD0A004D@CN-MBX05.HTC.COM.TW>
 <AF7C0ADF1FEABA4DABABB97411952A2EDD0A4F06@CN-MBX03.HTC.COM.TW>
 <20170515080535.GA22076@kroah.com>
 <AF7C0ADF1FEABA4DABABB97411952A2EDD0A4F84@CN-MBX03.HTC.COM.TW>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <AF7C0ADF1FEABA4DABABB97411952A2EDD0A4F84@CN-MBX03.HTC.COM.TW>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhiyuan_zhu@htc.com
Cc: vinmenon@codeaurora.org, linux-mm@kvack.org, skhiani@codeaurora.org, torvalds@linux-foundation.org, Jet_Li@htc.com

On Mon, May 15, 2017 at 08:22:38AM +0000, zhiyuan_zhu@htc.com wrote:
> Dear Greg, 
> 
> Very sorry my mail history is lost.
> 
> I found a part of ION memory will be return to system in android platform,
> But these memorys  cana??t accounted in low-memory-killer strategy.
> a?|
> And I also found ION memory comes from,  kmalloc/vmalloc/alloc pages/reserved memory.
> I understand reserved memory shouldn't accounted to free memory.
> But the memory which alloced by kmalloc/vmalloc/alloc pages, can be reclaimed.
> 
> But the low-memory killer can't accounted this part,
> Many thanks.
> 
> Code location, 
>    ---> drivers/staging/android/lowmemorykiller.c  A -> lowmem_scan

That file is gone from the latest kernel release, sorry.  So there's not
much we can do about this code anymore.

See the mailing list archives for what should be used instead of this
code, there is a plan for what to do.

Also note that the ION code has had a lot of reworks lately as well.

good luck!

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
