Received: by wa-out-1112.google.com with SMTP id m33so925648wag.8
        for <linux-mm@kvack.org>; Sat, 09 Feb 2008 02:48:26 -0800 (PST)
Message-ID: <ce9e96720802090248j724e3abdkf6a2788cb1354626@mail.gmail.com>
Date: Sat, 9 Feb 2008 16:18:26 +0530
From: "Vedang - 1337 u|33r h4x0r" <ved.manerikar@gmail.com>
Subject: reserving virtual addresses
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I have hardcoded virtual addresses in my code. Is there any way that I
can insure that allocation of physical pages occurs only to this
particular set of addreses?

get_vm_area() returns virtual area dynamically. This is not the
scenario I desire.

I have heard about reserving virtual addresses (at boot time, possibly
modifying the kernel code) but I couldn't find any method to do this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
