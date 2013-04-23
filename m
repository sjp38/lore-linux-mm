Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 647936B0034
	for <linux-mm@kvack.org>; Tue, 23 Apr 2013 08:08:22 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id w11so395767pde.37
        for <linux-mm@kvack.org>; Tue, 23 Apr 2013 05:08:21 -0700 (PDT)
Date: Tue, 23 Apr 2013 20:25:42 +0800
From: Zheng Liu <gnehzuil.liu@gmail.com>
Subject: [question] call mark_page_accessed() in minor fault
Message-ID: <20130423122542.GA5638@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: muming.wq@taobao.com

Hi all,

Recently we meet a performance regression about mmaped page.  When we upgrade
our product system from 2.6.18 kernel to a latest kernel, such as 2.6.32 kernel,
we will find that mmaped pages are reclaimed very quickly.  We found that when
we hit a minor fault mark_page_accessed() is called in 2.6.18 kernel, but in
2.6.32 kernel we don't call mark_page_accesed().  This means that mmaped pages
in 2.6.18 kernel are activated and moved into active list.  While in 2.6.32
kernel mmaped pages are still kept in inactive list.

So my question is why we call mark_page_accessed() in 2.6.18 kernel, but don't
call it in 2.6.32 kernel.  Has any reason here?

Thanks in advance,
						- Zheng

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
