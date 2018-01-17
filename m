Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id A1B996B028C
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 16:18:08 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id 31so9187724wru.0
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 13:18:08 -0800 (PST)
Received: from outpost3.zedat.fu-berlin.de (outpost3.zedat.fu-berlin.de. [130.133.4.78])
        by mx.google.com with ESMTPS id k17si4082245eda.24.2018.01.17.13.18.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jan 2018 13:18:07 -0800 (PST)
Subject: Re: [PATCH v6 20/99] ida: Convert to XArray
References: <20180117202203.19756-1-willy@infradead.org>
 <20180117202203.19756-21-willy@infradead.org>
From: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Message-ID: <e8c42206-e4d7-dda3-2bb7-2c1faa6ff5be@physik.fu-berlin.de>
Date: Wed, 17 Jan 2018 22:17:55 +0100
MIME-Version: 1.0
In-Reply-To: <20180117202203.19756-21-willy@infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, Bjorn Andersson <bjorn.andersson@linaro.org>, Stefano Stabellini <sstabellini@kernel.org>, iommu@lists.linux-foundation.org, linux-remoteproc@vger.kernel.org, linux-s390@vger.kernel.org, intel-gfx@lists.freedesktop.org, cgroups@vger.kernel.org, linux-sh@vger.kernel.org, David Howells <dhowells@redhat.com>

Hi Matthew!

On 01/17/2018 09:20 PM, Matthew Wilcox wrote:
> Use the xarray infrstructure like we used the radix tree infrastructure.
> This lets us get rid of idr_get_free() from the radix tree code.

There's a typo: infrstructure => infratructure

Cheers,
Adrian

-- 
 .''`.  John Paul Adrian Glaubitz
: :' :  Debian Developer - glaubitz@debian.org
`. `'   Freie Universitaet Berlin - glaubitz@physik.fu-berlin.de
  `-    GPG: 62FF 8A75 84E0 2956 9546  0006 7426 3B37 F5B5 F913

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
