Content-Type: text/plain;
  charset="iso-8859-1"
From: Ed Tomlinson <tomlins@cam.org>
Subject: 35-mm1 triggers watchdog
Date: Tue, 17 Sep 2002 07:38:48 -0400
References: <3D86BE4F.75C9B6CC@digeo.com> <20020917072716.GN3530@holomorphy.com> <3D86E19B.6476A9EA@digeo.com>
In-Reply-To: <3D86E19B.6476A9EA@digeo.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <200209170738.48565.tomlins@cam.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Andrew,

I have had 35-mm1 reboot twice via the software watchdog.  What is the best
way to debug this.  I do have a serial term and can rebuild patched with the 
kernel debugger, just need some instructions on how to catch the stall and
what info to gather.  Is there a good FAQ on kernel debugger?

Kernel is 35-mm1 UP no preempth, plus ide probe fixes & a corrected slab callback 
patch.

TIA
Ed
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
