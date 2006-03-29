Received: by wproxy.gmail.com with SMTP id i23so107385wra
        for <linux-mm@kvack.org>; Tue, 28 Mar 2006 22:46:13 -0800 (PST)
Message-ID: <4536bb730603282246m601a2e01q7cd0ecbd00ca4e24@mail.gmail.com>
Date: Wed, 29 Mar 2006 12:16:12 +0530
From: VASM <vasm85@gmail.com>
Subject: Setting the PSE bit
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi ,
      I need some help for my project , I have 1024 contiguous 4 kb
pages in the memory (aligned to a 4mb boundary ) , i want to convert
these pages into one 4M page , I have written code in
do_anonymous_page()  , i have trapped my test program (which has a
mmap call for anonymous memory) in side this function and I want this
to work for this test process only , AFAIK the changes that need to be
done are , an new mk_pte_large should be added  where the PSE bit is
set and then use set_pte.
but is there any thing else that needs to be done , do we need to set
the pse bit in the pgd  , is yes , how ?
I am working on a intel 32 platform , I have read somewhere that a bit
in cr4 also needs to be set , is it already done or I'll have to do it
now.
and is there anything more that has to be done.

working on 2.4.32

--
Vasm

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
