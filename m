Message-ID: <20020905194735.79408.qmail@web14504.mail.yahoo.com>
Date: Thu, 5 Sep 2002 12:47:35 -0700 (PDT)
From: vyas niranjan <vyas_nir@yahoo.com>
Subject: 4MB of physical contiguous memory allocation in Linux
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

HI,

   I am writing a driver whereI am trying to allocate
4MB of Physical contiguous memory. Using
__get_free_pages, I can allocate maximum of 512 pages
in Linux. Is there any way of allocating 4MB of
Physical contiguous memory in Linux??

Thanks and Regards

__________________________________________________
Do You Yahoo!?
Yahoo! Finance - Get real-time stock quotes
http://finance.yahoo.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
