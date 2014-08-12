Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id AAD9B6B0035
	for <linux-mm@kvack.org>; Tue, 12 Aug 2014 17:40:56 -0400 (EDT)
Received: by mail-wi0-f174.google.com with SMTP id d1so6527666wiv.7
        for <linux-mm@kvack.org>; Tue, 12 Aug 2014 14:40:56 -0700 (PDT)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.194])
        by mx.google.com with ESMTP id ho4si32275120wjb.122.2014.08.12.14.40.54
        for <linux-mm@kvack.org>;
        Tue, 12 Aug 2014 14:40:54 -0700 (PDT)
Date: Wed, 13 Aug 2014 00:40:51 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: x86: vmalloc and THP
Message-ID: <20140812214051.GA17497@node.dhcp.inet.fi>
References: <53E99F86.5020100@scalemp.com>
 <20140812060745.GA7987@node.dhcp.inet.fi>
 <53EA3EE4.6090100@scalemp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53EA3EE4.6090100@scalemp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oren Twaig <oren@scalemp.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, "Shai Fultheim (Shai@ScaleMP.com)" <Shai@scalemp.com>

On Tue, Aug 12, 2014 at 07:20:52PM +0300, Oren Twaig wrote:
> >What's the point to use vmalloc() in this case?
> I've noticed that some lock/s are using linear addresses which are
> located at 0xffffc901922b4500 and from what I understand
> from mm.txt (kernel 3.0.101):
> *ffffc90000000000 - ffffe8ffffffffff (=45 bits) vmalloc/ioremap space
> 
> *So I'm not sure who/how/why this lock got allocated there, but obviously
> it is using that linear set. No ?

It would be nice to know what lock it was, but nothing is inherently wrong
with lock in vmalloc space.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
