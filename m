Received: from inergen.sybase.com (inergen.sybase.com [192.138.151.43])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA28218
	for <linux-mm@kvack.org>; Wed, 27 Jan 1999 12:54:21 -0500
Received: from smtp2.sybase.com (sybgate2.sybase.com [130.214.88.21])
          by inergen.sybase.com (8.8.4/8.8.4) with ESMTP
	  id JAA05686 for <linux-mm@kvack.org>; Wed, 27 Jan 1999 09:55:39 -0800 (PST)
Received: from chicago_notes_1.sybase.com (chicago-notes-1.sybase.com [157.133.46.3])
          by smtp2.sybase.com (8.8.4/8.8.4) with SMTP
	  id JAA12765 for <linux-mm@kvack.org>; Wed, 27 Jan 1999 09:54:12 -0800 (PST)
Message-ID: <36AF51EE.711C8FC7@sybase.com>
Date: Wed, 27 Jan 1999 11:50:38 -0600
From: Jason Froebe <jfroebe@sybase.com>
MIME-Version: 1.0
Subject: Shared memory segment > 1gb
Content-Type: multipart/mixed;
 boundary="------------349FC7D7921295F50568EDC2"
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------349FC7D7921295F50568EDC2
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Hi,

I'm trying to get a shared memory segment of just under 2 gb.  So
far, I've been able to get a 893mb shared segment by altering the
_SHM_IDX_BITS to 18 in include/asm/shmparam.h using the 2.2.0
kernel.  I'm assuming I can set the _SHM_IDX_BITS to 19 without a
problem (more overhead though), but since this is my "working"
computer, I don't want any surprises.  is this possible without
breaking something?  I glanced at the code but didn't see any
obvious "gotchas".

Don't ask why I don't use multiple segments.  It's not my
decision.

Jason

--------------349FC7D7921295F50568EDC2
Content-Type: text/x-vcard; charset=us-ascii;
 name="jfroebe.vcf"
Content-Transfer-Encoding: 7bit
Content-Description: Card for Jason Froebe
Content-Disposition: attachment;
 filename="jfroebe.vcf"

begin:vcard 
n:Froebe;Jason
tel;fax:773-864-7288
tel;work:1-800-8SYBASE
x-mozilla-html:TRUE
url:http://www.sybase.com
org:Sybase, Inc.;Technical Support
adr:;;8755 W. Higgins Road Suite 1000	;Chicago;IL;60631;USA
version:2.1
email;internet:jfroebe@sybase.com
title:Technical Support Engineer
x-mozilla-cpt:;20256
fn:Jason Froebe
end:vcard

--------------349FC7D7921295F50568EDC2--

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
