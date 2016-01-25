Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 192576B0005
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 07:04:00 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id 123so62647267wmz.0
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 04:04:00 -0800 (PST)
Received: from mail-wm0-x22e.google.com (mail-wm0-x22e.google.com. [2a00:1450:400c:c09::22e])
        by mx.google.com with ESMTPS id 189si24019016wme.76.2016.01.25.04.03.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jan 2016 04:03:58 -0800 (PST)
Received: by mail-wm0-x22e.google.com with SMTP id u188so62876846wmu.1
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 04:03:58 -0800 (PST)
Date: Mon, 25 Jan 2016 14:03:56 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: valgrind: mmap ENOMEM
Message-ID: <20160125120356.GA12078@node.shutemov.name>
References: <20160125134920.66e514e9@mdontu-l.dsd.bitdefender.biz>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20160125134920.66e514e9@mdontu-l.dsd.bitdefender.biz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mihai =?utf-8?B?RG9uyJt1?= <mihai.dontu@gmail.com>
Cc: linux-kernel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, linux-mm@kvack.org

On Mon, Jan 25, 2016 at 01:49:20PM +0200, Mihai DonE?u wrote:
> Hi,
> 
> I just moved to 4.5-rc1 and noticed this little gem while trying to
> debug an issue with skype:
> 
>   $ valgrind skype
>   valgrind: mmap(0x60b000, 8192) failed in UME with error 12 (Cannot allocate memory).
> 
> 4.4 works fine. I have attached my kernel config.

http://lkml.kernel.org/r/145358234948.18573.2681359119037889087.stgit@zurg

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
