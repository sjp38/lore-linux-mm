Received: by wf-out-1314.google.com with SMTP id 28so3709439wfc.11
        for <linux-mm@kvack.org>; Thu, 10 Jul 2008 03:54:26 -0700 (PDT)
Message-ID: <19f34abd0807100354o4f79b75bo174d756da8459d37@mail.gmail.com>
Date: Thu, 10 Jul 2008 12:54:26 +0200
From: "Vegard Nossum" <vegard.nossum@gmail.com>
Subject: swapon/swapoff in a loop -- ever-decreasing priority field
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

I find that running swapon/swapoff in a loop will decrement the
"Priority" field of the swap partition once per iteration. This
doesn't seem quite correct, as it will eventually lead to an
underflow.

(Though, by my calculations, it would take around 620 days of constant
swapoff/swapon to reach this condition, so it's hardly a real-life
problem.)

Is this something that should be fixed, though?


Vegard

-- 
"The animistic metaphor of the bug that maliciously sneaked in while
the programmer was not looking is intellectually dishonest as it
disguises that the error is the programmer's own creation."
	-- E. W. Dijkstra, EWD1036

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
