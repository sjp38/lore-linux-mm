Message-Id: <20080129154900.145303789@szeredi.hu>
Date: Tue, 29 Jan 2008 16:49:00 +0100
From: Miklos Szeredi <miklos@szeredi.hu>
Subject: [patch 0/6] mm: bdi: updates
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: a.p.zijlstra@chello.nl, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a series from Peter Zijlstra, with various updates by me.  The
patchset mostly deals with exporting BDI attributes in sysfs.

Should be in a mergeable state, at least into -mm.

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
