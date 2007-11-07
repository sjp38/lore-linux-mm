Message-Id: <20071107004357.233417373@sgi.com>
Date: Tue, 06 Nov 2007 16:43:57 -0800
From: clameter@sgi.com
Subject: [patch 0/2] X86_64 configurable stack size
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

These two patches the configuration of the stack size on x86_64.

Prior discussion on these (this version does not provide a fallback):

http://marc.info/?l=linux-mm&m=119147073128193&w=2
http://marc.info/?l=linux-mm&m=119147072506052&w=2

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
