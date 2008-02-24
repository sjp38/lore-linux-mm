Date: Sun, 24 Feb 2008 15:47:11 +0100
From: =?utf-8?B?SsO2cm4=?= Engel <joern@logfs.org>
Subject: Page scan keeps touching kernel text pages
Message-ID: <20080224144710.GD31293@lazybastard.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

While tracking down some unrelated bug I noticed that shrink_page_list()
keeps testing very low page numbers (aka kernel text) until deciding
that the page lacks a mapping and cannot get freed.  Looks like a waste
of cpu and cachelines to me.

Is there a better reason for this behaviour than lack of a patch?

JA?rn

-- 
Joern's library part 11:
http://www.unicom.com/pw/reply-to-harmful.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
