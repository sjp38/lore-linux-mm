Message-ID: <20011204085740.63317.qmail@web12001.mail.yahoo.com>
Date: Tue, 4 Dec 2001 00:57:40 -0800 (PST)
From: Anumula Venkat <anumulavenkat@yahoo.com>
Subject: runtimeimage of kernel module
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello Friends,


    Can anybody tell me how runtime image of kernel
module will be formed ? 
     I know that all kernel modules will run in one
address space. And for user level applications stack
will be formed at 0xbfff.. ( something of this kind ).

My doubt is where does the stack will be formed for
kernel modules ?


Thanks in advance
Regards
Venkat   

=====
'Arise, awake and stop not till the GOAL is reached' -- Swami Vivekananda

__________________________________________________
Do You Yahoo!?
Buy the perfect holiday gifts at Yahoo! Shopping.
http://shopping.yahoo.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
