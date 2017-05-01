Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id BE5486B0038
	for <linux-mm@kvack.org>; Mon,  1 May 2017 05:33:11 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id i7so2942945wmf.19
        for <linux-mm@kvack.org>; Mon, 01 May 2017 02:33:11 -0700 (PDT)
Received: from mail-wm0-x235.google.com (mail-wm0-x235.google.com. [2a00:1450:400c:c09::235])
        by mx.google.com with ESMTPS id h82si6994179wmh.131.2017.05.01.02.33.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 May 2017 02:33:10 -0700 (PDT)
Received: by mail-wm0-x235.google.com with SMTP id u65so84612335wmu.1
        for <linux-mm@kvack.org>; Mon, 01 May 2017 02:33:10 -0700 (PDT)
Date: Mon, 1 May 2017 12:33:07 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v2] mm, zone_device: replace {get,
 put}_zone_device_page() with a single reference
Message-ID: <20170501093307.cej5kvu7bu6xcu4q@node.shutemov.name>
References: <20170428063913.iz6xjcxblecofjlq@gmail.com>
 <149339998297.24933.1129582806028305912.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20170429141838.tkyfxhldmwypyipz@gmail.com>
 <CAPcyv4i8WrNPzu_-Lu1uKi8NT-vj1PF0h0SW_Pi=QGn5PPhQfQ@mail.gmail.com>
 <20170501071259.5vya524wcdddm42b@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170501071259.5vya524wcdddm42b@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Dan Williams <dan.j.williams@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Logan Gunthorpe <logang@deltatee.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>

On Mon, May 01, 2017 at 09:12:59AM +0200, Ingo Molnar wrote:
> ... is this extension to the changelog correct?

Looks good to me.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
