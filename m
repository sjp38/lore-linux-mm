Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id E22796B0253
	for <linux-mm@kvack.org>; Mon, 11 Jul 2016 21:34:56 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id q62so3082143oih.0
        for <linux-mm@kvack.org>; Mon, 11 Jul 2016 18:34:56 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id w142si180782oia.276.2016.07.11.18.34.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 11 Jul 2016 18:34:56 -0700 (PDT)
Message-ID: <57844872.1060806@huawei.com>
Date: Tue, 12 Jul 2016 09:31:30 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: a question about protection_map[]
References: <5783710E.3070602@huawei.com> <20160711133015.GA8028@node.shutemov.name>
In-Reply-To: <20160711133015.GA8028@node.shutemov.name>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: alan@lxorguk.ukuu.org.uk, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2016/7/11 21:30, Kirill A. Shutemov wrote:

> On Mon, Jul 11, 2016 at 06:12:30PM +0800, Xishi Qiu wrote:
>> Hi,
>>
>> We can use mprotect to set read only or read/write.
>>
>> mprotect_fixup()
>> 	vma_set_page_prot()
>> 		vm_pgprot_modify()
>> 			vm_get_page_prot()
>> 				protection_map[vm_flags & (VM_READ|VM_WRITE|VM_EXEC|VM_SHARED)]
>>
>> The following code shows that prots from __P001(PROT_READ) and __P010(PROT_WRITE)
>> are the same, so how does it distinguish read only or read/write from mprotect?
> 
> It doesn't.
> 
> Write protection will be removed by fault handler on next write access to
> the page. Somewhat suboptiomal, but zero page implemenation relies on this
> to work properly.
> 

Hi Kirill,

I know, PAGE_READONLY and PAGE_COPY are both missed _PAGE_RW,
so it will cause page fault, then we will set new prot flag from
vma, right?

Thanks,
Xishi Qiu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
