Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id CA0BA6B13F0
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 16:06:08 -0500 (EST)
Received: by wibhj13 with SMTP id hj13so143173wib.14
        for <linux-mm@kvack.org>; Tue, 14 Feb 2012 13:06:07 -0800 (PST)
MIME-Version: 1.0
Date: Tue, 14 Feb 2012 16:06:07 -0500
Message-ID: <CAG4AFWYJXR-b8zDew+ia5xSCNJ2uZBhXvre6NxtMNVxtY9FsKg@mail.gmail.com>
Subject: How to really write-protect a page
From: Jidong Xiao <jidong.xiao@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Hi,

For some reason, I want to write protect a special page, but I don't
know how to set it as read-only.

I am reading the book "Understanding The Linux Virtual Memory Manager".

In section 5.6.4, there is saying:

"During fork, the PTEs of the two processes are made read-only so that
when a write occurs there will be a page fault. Linux recognises a COW
page because even though the PTE is write protected, the controlling
VMA shows the region is writable."

My question is, if I really want write protect a page, say, I don't
want a copy-on-write happens, I just hope the page is really
read-only, can I achieve that by setting "the controlling VMA" as
non-writable? Or how to do that?

Thank you!

Regards
Jidong

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
