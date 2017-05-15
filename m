Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id AF00F6B0038
	for <linux-mm@kvack.org>; Mon, 15 May 2017 04:05:46 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id o25so106576552pgc.1
        for <linux-mm@kvack.org>; Mon, 15 May 2017 01:05:46 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id e5si10348080pga.100.2017.05.15.01.05.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 May 2017 01:05:46 -0700 (PDT)
Date: Mon, 15 May 2017 10:05:35 +0200
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: Low memory killer problem
Message-ID: <20170515080535.GA22076@kroah.com>
References: <AF7C0ADF1FEABA4DABABB97411952A2EDD0A004D@CN-MBX05.HTC.COM.TW>
 <AF7C0ADF1FEABA4DABABB97411952A2EDD0A4F06@CN-MBX03.HTC.COM.TW>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <AF7C0ADF1FEABA4DABABB97411952A2EDD0A4F06@CN-MBX03.HTC.COM.TW>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhiyuan_zhu@htc.com
Cc: vinmenon@codeaurora.org, linux-mm@kvack.org, skhiani@codeaurora.org, torvalds@linux-foundation.org

On Mon, May 15, 2017 at 07:25:20AM +0000, zhiyuan_zhu@htc.com wrote:
> Loop MM maintainers,
> 
>  
> 
> Dear All,
> 
>  
> 
> Who can talk about this problem? Thanks.

What problem?

> Maybe this is lowmemory killera??s bug ?

This code is now removed from the kernel, so I doubt there could be a
bug in it :)

> ION memory is complex now, we need to have a breakdown for them, I think.

What do you mean by this?

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
