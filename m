Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f169.google.com (mail-ob0-f169.google.com [209.85.214.169])
	by kanga.kvack.org (Postfix) with ESMTP id 29D406B0032
	for <linux-mm@kvack.org>; Fri, 30 Jan 2015 12:26:20 -0500 (EST)
Received: by mail-ob0-f169.google.com with SMTP id va8so25022663obc.0
        for <linux-mm@kvack.org>; Fri, 30 Jan 2015 09:26:19 -0800 (PST)
Received: from bh-25.webhostbox.net (bh-25.webhostbox.net. [208.91.199.152])
        by mx.google.com with ESMTPS id cs4si5566497oeb.31.2015.01.30.09.26.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 30 Jan 2015 09:26:19 -0800 (PST)
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YHFKl-001kQw-Ke
	for linux-mm@kvack.org; Fri, 30 Jan 2015 17:26:19 +0000
Date: Fri, 30 Jan 2015 09:26:13 -0800
From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH 00/19] expose page table levels on Kconfig leve
Message-ID: <20150130172613.GA12367@roeck-us.net>
References: <1422629008-13689-1-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1422629008-13689-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jan 30, 2015 at 04:43:09PM +0200, Kirill A. Shutemov wrote:
> I've failed my attempt on split up mm_struct into separate header file to
> be able to use defines from <asm/pgtable.h> to define mm_struct: it causes
> too much breakage and requires massive de-inlining of some architectures
> (notably ARM and S390 with PGSTE).
> 
> This is other approach: expose number of page table levels on Kconfig
> level and use it to get rid of nr_pmds in mm_struct.
> 
Hi Kirill,

Can I pull this series from somewhere ?

Thanks,
Guenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
