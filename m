Received: from bix (build.pdx.osdl.net [172.20.1.2])
	by mail.osdl.org (8.11.6/8.11.6) with SMTP id iABAeL926737
	for <linux-mm@kvack.org>; Thu, 11 Nov 2004 02:40:28 -0800
Date: Thu, 11 Nov 2004 02:40:15 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: follow_page()
Message-Id: <20041111024015.7c50c13d.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Can anyone think of a sane reason why this thing is marking the page dirty?

I mean, we're supposed to mark the page dirty _after_ modifying its
contents.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
