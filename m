Received: from cthulhu.engr.sgi.com (cthulhu.engr.sgi.com [192.26.80.2]) by pneumatic-tube.sgi.com (980327.SGI.8.8.8-aspam/980310.SGI-aspam) via ESMTP id LAA09979
	for <@external-mail-relay.sgi.com:linux-mm@kvack.org>; Fri, 22 Sep 2000 11:40:40 -0700 (PDT)
	mail_from (ananth@sgi.com)
Received: from madurai.engr.sgi.com (madurai.engr.sgi.com [163.154.5.75])
	by cthulhu.engr.sgi.com (980427.SGI.8.8.8/970903.SGI.AUTOCF)
	via ESMTP id LAA13917
	for <@cthulhu.engr.sgi.com:linux-mm@kvack.org>;
	Fri, 22 Sep 2000 11:33:49 -0700 (PDT)
	mail_from (ananth@sgi.com)
Received: from sgi.com (mango.engr.sgi.com [163.154.5.76]) by madurai.engr.sgi.com (980427.SGI.8.8.8/970903.SGI.AUTOCF) via ESMTP id LAA63688 for <linux-mm@kvack.org>; Fri, 22 Sep 2000 11:30:01 -0700 (PDT)
Message-ID: <39CBA69D.D6FCFB37@sgi.com>
Date: Fri, 22 Sep 2000 11:36:13 -0700
From: Rajagopal Ananthanarayanan <ananth@sgi.com>
MIME-Version: 1.0
Subject: try_to_free_pages not used?
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I'm not sure whether this is part of Rik's
recent changes (must be), but, try_to_free_pages()
is not used anymore in test9-pre4 ...

Should it be removed?
 
-- 
--------------------------------------------------------------------------
Rajagopal Ananthanarayanan ("ananth")
Member Technical Staff, SGI.
--------------------------------------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
