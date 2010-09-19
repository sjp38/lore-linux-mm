Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 8D9D66B007B
	for <linux-mm@kvack.org>; Sun, 19 Sep 2010 10:56:07 -0400 (EDT)
Received: by eyh5 with SMTP id 5so2011330eyh.14
        for <linux-mm@kvack.org>; Sun, 19 Sep 2010 07:56:05 -0700 (PDT)
MIME-Version: 1.0
Date: Sun, 19 Sep 2010 20:26:05 +0530
Message-ID: <AANLkTi=-Npp=YWqEG6YpQ+EzP0PtMacJaB18roDFZ40E@mail.gmail.com>
Subject: setting and removing break-point from within kernel
From: Uma shankar <shankar.vk@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: linux-arm-kernel@lists.arm.linux.org.uk, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

         I am trying to debug  a subtle  timing-dependent  bug in kernel.

I found that  if  I could set up  a break-point  from within  kernel
at run-time, this  would help.

The condition to trigger is
"If  0 is written  at  virtual address  0xCEC8F004 , then stop".

The address is on kernel-stack

My  SOC has a onchip  JTAG-based  debug block.

What I have in mind  is  to do as  below -

signed long __sched schedule_timeout(signed long timeout)
{
 struct timer_list timer;
 unsigned long expire;
// some  kernel code

// setup  conditional break-point

// some  kernel code  runs here
// some  kernel code
// some  kernel code

//  remove  the break-point

// some  kernel code  runs here

}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
