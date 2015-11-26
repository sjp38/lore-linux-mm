Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id DDA9B6B0038
	for <linux-mm@kvack.org>; Thu, 26 Nov 2015 11:05:13 -0500 (EST)
Received: by wmuu63 with SMTP id u63so26835434wmu.0
        for <linux-mm@kvack.org>; Thu, 26 Nov 2015 08:05:13 -0800 (PST)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id it3si42206388wjb.195.2015.11.26.08.05.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Nov 2015 08:05:12 -0800 (PST)
Subject: Re: linux-next: Tree for Nov 26 (mm/page_owner.c)
References: <20151126161655.281096bb@canb.auug.org.au>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <56572DB1.5070605@infradead.org>
Date: Thu, 26 Nov 2015 08:05:05 -0800
MIME-Version: 1.0
In-Reply-To: <20151126161655.281096bb@canb.auug.org.au>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>, linux-next@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, Linux MM <linux-mm@kvack.org>

On 11/25/15 21:16, Stephen Rothwell wrote:
> Hi all,
> 
> Reminder: there will be no linux-next release next week (Nov 30 - Dec 4).
> 
> Changes since 20151124:
> 

on i386:

mm/built-in.o: In function `read_page_owner':
page_owner.c:(.text+0x25d89): undefined reference to `migrate_reason_names'
mm/built-in.o: In function `__dump_page_owner':
(.text+0x26137): undefined reference to `migrate_reason_names'


when CONFIG_MIGRATION is not enabled.


-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
