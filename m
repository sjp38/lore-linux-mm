Received: from schroedinger.engr.sgi.com (schroedinger.engr.sgi.com [150.166.1.51])
	by relay2.corp.sgi.com (Postfix) with ESMTP id 401B1304093
	for <linux-mm@kvack.org>; Thu,  6 Mar 2008 14:46:36 -0800 (PST)
Received: from clameter (helo=localhost)
	by schroedinger.engr.sgi.com with local-esmtp (Exim 3.36 #1 (Debian))
	id 1JXOqy-0004Cx-00
	for <linux-mm@kvack.org>; Thu, 06 Mar 2008 14:46:20 -0800
Date: Thu, 6 Mar 2008 14:46:20 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Mel has mail problems? ... 
Message-ID: <Pine.LNX.4.64.0803061445450.15906@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: MULTIPART/Mixed; REPORT-TYPE=delivery-status; BOUNDARY="3BD1F11BD0.1204843479/gir.skynet.ie"
Content-ID: <Pine.LNX.4.64.0803061444561.15906@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--3BD1F11BD0.1204843479/gir.skynet.ie
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII
Content-ID: <Pine.LNX.4.64.0803061444562.15906@schroedinger.engr.sgi.com>
Content-Description: Notification

Segfault on the mail server? Any alternate addresses for Mel?

---------- Forwarded message ----------
Date: Thu,  6 Mar 2008 22:44:39 +0000 (GMT)
From: Mail Delivery System <MAILER-DAEMON@skynet.ie>
To: clameter@sgi.com
Subject: Undelivered Mail Returned to Sender

This is the mail system at host gir.skynet.ie.

I'm sorry to have to inform you that your message could not
be delivered to one or more recipients. It's attached below.

For further assistance, please send mail to postmaster.

If you do so, please include this problem report. You can
delete your own text from the attached returned message.

                   The mail system

<mel@csn.ul.ie>: Command died with status 139: "/usr/bin/procmail -a
    "$EXTENSION"". Command output: procmail: Exceeded LINEBUF Segmentation
    fault
--3BD1F11BD0.1204843479/gir.skynet.ie
Content-Type: MESSAGE/DELIVERY-STATUS; CHARSET=US-ASCII
Content-ID: <Pine.LNX.4.64.0803061444563.15906@schroedinger.engr.sgi.com>
Content-Description: Delivery report

Reporting-MTA: dns; gir.skynet.ie
X-Postfix-Queue-ID: 3BD1F11BD0
X-Postfix-Sender: rfc822; clameter@sgi.com
Arrival-Date: Thu,  6 Mar 2008 22:44:22 +0000 (GMT)

Final-Recipient: rfc822; mel@csn.ul.ie
Original-Recipient: rfc822;mel@csn.ul.ie
Action: failed
Status: 5.3.0
Diagnostic-Code: x-unix; procmail: Exceeded LINEBUF Segmentation fault

--3BD1F11BD0.1204843479/gir.skynet.ie
Content-Type: MESSAGE/RFC822; CHARSET=US-ASCII
Content-ID: <Pine.LNX.4.64.0803061444564.15906@schroedinger.engr.sgi.com>
Content-Description: Undelivered Message

Received: from localhost (localhost [127.0.0.1])
	by gir.skynet.ie (Postfix) with ESMTP id 3BD1F11BD0
	for <mel@csn.ul.ie>; Thu,  6 Mar 2008 22:44:22 +0000 (GMT)
X-Virus-Scanned: Debian amavisd-new at gir.skynet.ie
Received: from gir.skynet.ie ([127.0.0.1])
	by localhost (gir.skynet.ie [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 44eBbf0bSQ4e for <mel@csn.ul.ie>;
	Thu,  6 Mar 2008 22:44:22 +0000 (GMT)
Received: from relay.sgi.com (relay1.sgi.com [192.48.171.29])
	by gir.skynet.ie (Postfix) with ESMTP id EB3B911BC9
	for <mel@csn.ul.ie>; Thu,  6 Mar 2008 22:44:13 +0000 (GMT)
Received: from schroedinger.engr.sgi.com (schroedinger.engr.sgi.com [150.166.1.51])
	by relay1.corp.sgi.com (Postfix) with ESMTP id 0C7DE8F80C0;
	Thu,  6 Mar 2008 14:44:09 -0800 (PST)
Received: from clameter (helo=localhost)
	by schroedinger.engr.sgi.com with local-esmtp (Exim 3.36 #1 (Debian))
	id 1JXOob-0004C6-00; Thu, 06 Mar 2008 14:43:53 -0800
Date: Thu, 6 Mar 2008 14:43:53 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
X-X-Sender: clameter@schroedinger.engr.sgi.com
To: Sam Ravnborg <sam@ravnborg.org>
cc: Andrew Morton <akpm@linux-foundation.org>, ak@suse.de,
    Mel Gorman <mel@csn.ul.ie>, apw@shadowen.org,
    KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>,
    KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>,
    Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
Subject: Re: [patch 2/8] Kbuild: Create a way to create preprocessor constants
 from C expressions
In-Reply-To: <20080306210005.GB29026@uranus.ravnborg.org>
Message-ID: <Pine.LNX.4.64.0803061442010.15906@schroedinger.engr.sgi.com>
References: <20080305223815.574326323@sgi.com> <20080305223845.436523065@sgi.com>
 <20080305200800.23ee10ec.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0803061217240.14140@schroedinger.engr.sgi.com>
 <20080306210005.GB29026@uranus.ravnborg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII

Hmmm.. Even after the Sam's fixes: I still have the recursion probblem 
that include/linux/bounds.h needs to exist and provide some value for 
the constants in order to create kernel/bounds.c. And kernel/bounds.c is 
needed then to create bounds.s which creates bounds.h. Argh!



--3BD1F11BD0.1204843479/gir.skynet.ie--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
