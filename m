Date: 20 Sep 2001 06:54:44 -0000
Message-ID: <20010920065444.10415.qmail@mailweb13.rediffmail.com>
MIME-Version: 1.0
Subject: -__PAGE_OFFSET
From: "amey d inamdar" <iamey@rediffmail.com>
Content-ID: <Thu_Sep_20_12_24_44_IST_2001_0@mailweb13.rediffmail.com>
Content-type: text/plain
Content-Description: Body
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello everybody,
     While running through source of 2.4 kernel, in head.S, I found the 
line
86 :   movl $pg0-__PAGE_OFFSET,%edi

    I am not getting, at this point there is no virtual address & $pg0 
itself contains physical address of first page table, then why to 
subtract 3GB from the physical address?
      Thanx in anticipation.

 -  Amey


 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
