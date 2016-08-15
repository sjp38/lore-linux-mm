Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 36AB56B0262
	for <linux-mm@kvack.org>; Mon, 15 Aug 2016 11:34:00 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id s207so150245983oie.1
        for <linux-mm@kvack.org>; Mon, 15 Aug 2016 08:34:00 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id l76si304683iod.245.2016.08.15.08.33.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Aug 2016 08:33:59 -0700 (PDT)
Subject: Re: linux-next: Tree for Aug 15 (mm/khugepaged.c)
References: <20160815132648.575092f2@canb.auug.org.au>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <61b8f95c-652f-c083-80f8-cef587bd5ea6@infradead.org>
Date: Mon, 15 Aug 2016 08:33:55 -0700
MIME-Version: 1.0
In-Reply-To: <20160815132648.575092f2@canb.auug.org.au>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>, linux-next@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

On 08/14/16 20:26, Stephen Rothwell wrote:
> Hi all,
> 
> Changes since 20160812:
> 

on i386:
when CONFIG_SYSFS is not enabled:

mm/built-in.o: In function `khugepaged_defrag_store':
khugepaged.c:(.text+0x47a37): undefined reference to `single_hugepage_flag_store'
mm/built-in.o: In function `khugepaged_defrag_show':
khugepaged.c:(.text+0x47a5e): undefined reference to `single_hugepage_flag_show'


-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
