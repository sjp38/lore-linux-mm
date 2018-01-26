Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3A9726B0009
	for <linux-mm@kvack.org>; Fri, 26 Jan 2018 14:41:05 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id x16so1003192pfe.20
        for <linux-mm@kvack.org>; Fri, 26 Jan 2018 11:41:05 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id h186si3378187pgc.707.2018.01.26.11.41.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 26 Jan 2018 11:41:03 -0800 (PST)
Date: Fri, 26 Jan 2018 11:40:58 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [Bug 198497] New: handle_mm_fault / xen_pmd_val /
 radix_tree_lookup_slot Null pointer
Message-ID: <20180126194058.GA31600@bombadil.infradead.org>
References: <bug-198497-27@https.bugzilla.kernel.org/>
 <20180118135518.639141f0b0ea8bb047ab6306@linux-foundation.org>
 <7ba7635e-249a-9071-75bb-7874506bd2b2@redhat.com>
 <20180119030447.GA26245@bombadil.infradead.org>
 <d38ff996-8294-81a6-075f-d7b2a60aa2f4@rimuhosting.com>
 <20180119132145.GB2897@bombadil.infradead.org>
 <9d2ddba4-3fb3-0fb4-a058-f2cfd1b05538@redhat.com>
 <32ab6fd6-e3c6-9489-8163-aa73861aa71a@rimuhosting.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <32ab6fd6-e3c6-9489-8163-aa73861aa71a@rimuhosting.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: xen@randomwebstuff.com
Cc: Laura Abbott <labbott@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org

On Fri, Jan 26, 2018 at 07:54:06PM +1300, xen@randomwebstuff.com wrote:
> Re-tried with the current latest 4.14 (4.14.15).  Received the following:
> 
> [2018-01-24 19:26:57] dev login: [44501.106868] BUG: unable to handle kernel
> NULL pointer dereference at 00000008
> [2018-01-25 07:47:50] [44501.106897] IP: __radix_tree_lookup+0x14/0xa0

Please try including this patch:

https://bugzilla.kernel.org/show_bug.cgi?id=198497#c7

And have you had the chance to run memtest86 yet?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
