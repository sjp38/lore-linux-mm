Received: from star4.planet.rcn.com.hk (star4.planet.rcn.com.hk [192.168.0.4])
	by uranus.planet.rcn.com.hk (8.11.6/linuxconf) with ESMTP id g0G6kRp09227
	for <linux-mm@kvack.org>; Wed, 16 Jan 2002 14:46:27 +0800
Subject: question in vmalloc
From: Joe Wong <joewong@shaolinmicro.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 16 Jan 2002 14:46:27 +0800
Message-Id: <1011163587.1038.2.camel@star4.planet.rcn.com.hk>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

  I am new to the kernel area. I would like to know if there is any
potentail problem on using vmalloc? If the memory returned by vmalloc
swappable? If so, how I can turn it to unswappable? I have a kernel
module to will preallocate some huge data strucutres using vmalloc when
loaded.

TIA.

- Joe





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
