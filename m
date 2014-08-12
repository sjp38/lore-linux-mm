Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f53.google.com (mail-la0-f53.google.com [209.85.215.53])
	by kanga.kvack.org (Postfix) with ESMTP id ABF476B0035
	for <linux-mm@kvack.org>; Tue, 12 Aug 2014 02:07:49 -0400 (EDT)
Received: by mail-la0-f53.google.com with SMTP id gl10so7349761lab.26
        for <linux-mm@kvack.org>; Mon, 11 Aug 2014 23:07:48 -0700 (PDT)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.193])
        by mx.google.com with ESMTP id g4si17052560lba.83.2014.08.11.23.07.46
        for <linux-mm@kvack.org>;
        Mon, 11 Aug 2014 23:07:47 -0700 (PDT)
Date: Tue, 12 Aug 2014 09:07:45 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: x86: vmalloc and THP
Message-ID: <20140812060745.GA7987@node.dhcp.inet.fi>
References: <53E99F86.5020100@scalemp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53E99F86.5020100@scalemp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oren Twaig <oren@scalemp.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, "Shai Fultheim (Shai@ScaleMP.com)" <Shai@scalemp.com>

On Tue, Aug 12, 2014 at 08:00:54AM +0300, Oren Twaig wrote:
> <html style="direction: ltr;">

plain/text, please.

>Hello,
>
>Does memory allocated using vmalloc() will be mapped using huge
>pages either directly or later by THP ? 

No. It's neither aligned properly, nor physically contiguous.

>If not, is there any fast way to change this behavior ? Maybe by
>changing the granularity/alignment of such allocations to allow such
>mapping ?

What's the point to use vmalloc() in this case?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
