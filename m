Received: from cthulhu.engr.sgi.com (cthulhu.engr.sgi.com [192.26.80.2]) by deliverator.sgi.com (980309.SGI.8.8.8-aspam-6.2/980310.SGI-aspam) via ESMTP id RAA15957
	for <@external-mail-relay.sgi.com:linux-mm@kvack.org>; Wed, 5 Jul 2000 17:58:51 -0700 (PDT)
	mail_from (ananth@sgi.com)
Received: from madurai.engr.sgi.com (madurai.engr.sgi.com [163.154.5.75])
	by cthulhu.engr.sgi.com (980427.SGI.8.8.8/970903.SGI.AUTOCF)
	via ESMTP id SAA72464
	for <@cthulhu.engr.sgi.com:linux-mm@kvack.org>;
	Wed, 5 Jul 2000 18:03:24 -0700 (PDT)
	mail_from (ananth@sgi.com)
Received: from sgi.com (mango.engr.sgi.com [163.154.5.76]) by madurai.engr.sgi.com (980427.SGI.8.8.8/970903.SGI.AUTOCF) via ESMTP id SAA68752 for <linux-mm@kvack.org>; Wed, 5 Jul 2000 18:00:17 -0700 (PDT)
Message-ID: <3963DB74.808D8D90@sgi.com>
Date: Wed, 05 Jul 2000 18:05:56 -0700
From: Rajagopal Ananthanarayanan <ananth@sgi.com>
MIME-Version: 1.0
Subject: waiting on writepage operation
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Noticed that filemap_write_page has a wait
parameter that is being unused. When called
from the swapout path, the calling routine
does not intend the operation to block ...
so it calls filemap_write_page with wait = 0.
However, the writepage operation of the
address space does not support the notion of
waiting. Is there a reason to hope that the
wait argument might become part of writepage()?
It will be great to work out a dead-lock situation
in XFS by simply bailing out of the writepage
if it was called with wait = 0.

Thanks for any suggestions,


--------------------------------------------------------------------------
Rajagopal Ananthanarayanan ("ananth")
Member Technical Staff, SGI.
--------------------------------------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
