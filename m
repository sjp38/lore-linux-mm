Received: from mail.intermedia.net ([207.5.44.129])
	by kvack.org (8.8.7/8.8.7) with SMTP id LAA26710
	for <linux-mm@kvack.org>; Tue, 4 May 1999 11:28:34 -0400
Received: from [193.159.8.35] by mail.colorfullife.com (NTMail 3.03.0017/1.abcr) with ESMTP id ra360845 for <linux-mm@kvack.org>; Tue, 4 May 1999 08:29:37 -0700
Message-ID: <004b01be970b$df3b4330$c80c17ac@clmsdev.local>
Reply-To: "Manfred Spraul" <masp0008@stud.uni-sb.de>
From: "Manfred Spraul" <manfreds@colorfullife.com>
Subject: Re: Hello
Date: Wed, 5 May 1999 17:27:44 +0200
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: "Stephen C. Tweedie" <sct@redhat.com>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: "Benjamin C.R. LaHaise" <blah@kvack.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>The newer addressing mode is the 3-level page tables available in
>PIIIs (and in later stepping PIIs, I think), which allow transparent
>access to all of physical memory up to 64G.  That's what I'm aiming
>for.
AFIAK it's the other way around:
the 3-level system is PAE, available since PPro,
and the 2-level system where only 4 MB PTE's can address
memory > 3 GB is the new system added for the P-II Xeon.
I think this mode was only added for WinNT:
Intel wants to support > 4 GB memory,
but the internal MM of NT is 2-level even in Windows-2000.
(according to www.osr.com).

Have you already started with your high-mem patch?

--
    Manfred


--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
