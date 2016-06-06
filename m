Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id E8EF76B0005
	for <linux-mm@kvack.org>; Mon,  6 Jun 2016 05:55:15 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 4so7595647wmz.1
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 02:55:15 -0700 (PDT)
Received: from mail-lf0-x22a.google.com (mail-lf0-x22a.google.com. [2a00:1450:4010:c07::22a])
        by mx.google.com with ESMTPS id 74si5373007ljf.84.2016.06.06.02.55.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Jun 2016 02:55:14 -0700 (PDT)
Received: by mail-lf0-x22a.google.com with SMTP id s64so91078551lfe.0
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 02:55:14 -0700 (PDT)
Date: Mon, 6 Jun 2016 12:55:11 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: Hugepages for tmpfs
Message-ID: <20160606095510.GA20248@node.shutemov.name>
References: <0B540039-9A94-43F8-9C16-EE04F68646AF@smogura.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <0B540039-9A94-43F8-9C16-EE04F68646AF@smogura.eu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?B?UmFkb3PFgmF3?= Smogura <mail@smogura.eu>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, Jun 06, 2016 at 06:30:06AM +0000, RadosA?aw Smogura wrote:
> Hi all,
> 
> Long time ago I was working on enabling huge pages for tmpfs and in terms for any filesystem. Recently I have found my work and I was thinking about restarting it with new kernel.
> 
> I wonder if there is some ongoing or finished work for huge pages in tmpfs?

https://lwn.net/Articles/684300/
https://lwn.net/Articles/686690/

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
