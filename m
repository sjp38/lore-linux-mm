Received: by pproxy.gmail.com with SMTP id i49so478317pyi
        for <linux-mm@kvack.org>; Fri, 28 Apr 2006 00:40:57 -0700 (PDT)
Message-ID: <aec7e5c30604280040p60cc7c7dqc6fb6fbdd9506a6b@mail.gmail.com>
Date: Fri, 28 Apr 2006 16:40:57 +0900
From: "Magnus Damm" <magnus.damm@gmail.com>
Subject: i386 and PAE: pud_present()
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi guys,

In file include/asm-i386/pgtable-3level.h:

On i386 with PAE enabled, shouldn't pud_present() return (pud_val(pud)
& _PAGE_PRESENT) instead of constant 1?

Today pud_present() returns constant 1 regardless of PAE or not. This
looks wrong to me, but maybe I'm misunderstanding how to fold the page
tables... =)

Thanks,

/ magnus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
