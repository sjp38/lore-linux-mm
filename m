Received: from mail.intermedia.net ([207.5.44.129])
	by kvack.org (8.8.7/8.8.7) with SMTP id KAA07333
	for <linux-mm@kvack.org>; Fri, 30 Apr 1999 10:03:37 -0400
Received: from [212.184.137.63] by mail.colorfullife.com (NTMail 3.03.0017/1.abcr) with ESMTP id va358067 for <linux-mm@kvack.org>; Fri, 30 Apr 1999 07:04:52 -0700
Message-ID: <004201be93da$e9c15df0$c80c17ac@clmsdev.local>
Reply-To: "Manfred Spraul" <masp0008@stud.uni-sb.de>
From: "Manfred Spraul" <manfreds@colorfullife.com>
Subject: Re: Hello
Date: Sat, 1 May 1999 16:00:01 +0200
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: "ak@muc.de" <ak@muc.de>
To: ak@muc.de
Cc: "Benjamin C.R. LaHaise" <blah@kvack.org>, linux-mm@kvack.org, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

>Not even the restriction that a single process cannot use more than 
>4GB-something?

Due to the 32 bit addressing, you can't use more that 4 Gb memory
at the same time.
I think you could create several memory mapped regions,
each e.g. 1 GB and map one at a time. 


Regards,
    Manfred



--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
