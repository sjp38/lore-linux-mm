Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f42.google.com (mail-oi0-f42.google.com [209.85.218.42])
	by kanga.kvack.org (Postfix) with ESMTP id 879166B0032
	for <linux-mm@kvack.org>; Fri, 23 Jan 2015 12:27:49 -0500 (EST)
Received: by mail-oi0-f42.google.com with SMTP id i138so5612807oig.1
        for <linux-mm@kvack.org>; Fri, 23 Jan 2015 09:27:49 -0800 (PST)
Received: from bear.ext.ti.com (bear.ext.ti.com. [192.94.94.41])
        by mx.google.com with ESMTPS id r82si1147506oig.11.2015.01.23.09.27.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 23 Jan 2015 09:27:48 -0800 (PST)
Date: Fri, 23 Jan 2015 11:27:36 -0600
From: Nishanth Menon <nm@ti.com>
Subject: Re: [next-20150119]regression (mm)?
Message-ID: <20150123172736.GA15392@kahuna>
References: <54BD33DC.40200@ti.com>
 <20150119174317.GK20386@saruman>
 <20150120001643.7D15AA8@black.fi.intel.com>
 <20150120114555.GA11502@n2100.arm.linux.org.uk>
 <20150120140546.DDCB8D4@black.fi.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20150120140546.DDCB8D4@black.fi.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>, Felipe Balbi <balbi@ti.com>, linux-mm@kvack.org, linux-next <linux-next@vger.kernel.org>, linux-omap <linux-omap@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On 16:05-20150120, Kirill A. Shutemov wrote:
[..]
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Reported-by: Nishanth Menon <nm@ti.com>
Just to close on this thread:
https://github.com/nmenon/kernel-test-logs/tree/next-20150123 looks good
and back to old status. Thank you folks for all the help.
-- 
Regards,
Nishanth Menon

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
