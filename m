Received: from exch-staff1.ul.ie ([136.201.1.64])
 by ul.ie (PMDF V5.2-32 #41949) with ESMTP id <0GK6005A0QU2HA@ul.ie> for
 linux-mm@kvack.org; Mon, 24 Sep 2001 22:10:50 +0100 (BST)
Content-return: allowed
Date: Mon, 24 Sep 2001 22:15:48 +0100
From: "Gabriel.Leen" <Gabriel.Leen@ul.ie>
Subject: RE: Process not given >890MB on a 4MB machine ?????????
Message-id: <5D2F375D116BD111844C00609763076E050D167E@exch-staff1.ul.ie>
MIME-version: 1.0
Content-type: text/plain
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Gabriel.Leen" <gabriel.leen@ul.ie>, 'Rik van Riel' <riel@conectiva.com.br>
Cc: Benjamin LaHaise <bcrl@redhat.com>, "'ebiederm@xmission.com'" <ebiederm@xmission.com>, "'tvignaud@mandrakesoft.com'" <tvignaud@mandrakesoft.com>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, "'brian@worldcontrol.com'" <brian@worldcontrol.com>, "'arjan@fenrus.demon.nl'" <arjan@fenrus.demon.nl>
List-ID: <linux-mm.kvack.org>

	Thank you ALL for your help !!
	And thank you Rik,
	Hoard is a fantastic library, I'm now able to get up to 3GB of
memory !!!!!!!!!!!!!!!!!!!!!!!!!!!!!! :)

	++++++++++++

	Unfortunately my program which is doing "alot" of calculations still
needs more space,

	Is there some way to enable 64 bit support (or something) and get
the swap space active,
	and give it another GB or so ?

	++++++++++++

	I know it sounds a bit crazy the amount of memory required, you see
I'm a PhD student,
	and I've been working on a model of a network for the past 2 years.
What I'm
	doing is formally verifying it and the calculations involved are
enormous !!!
	To finish my work I need to run this computation to completion and
get the results.

	If there are suggestions ideas they are very much appreciated.

	Again thank you ALL for your help,
	Gabriel


+++++++++++++++++++++++++
> Rik van Riel wrote :
>
> On Fri, 21 Sep 2001, Gabriel.Leen wrote:
>
> > Unfortunately the package which I am using is a pre-compiled
> > distribution, so that limits what I can do with it :(
>
> 1) install the hoard malloc library
> 2) LD_PRELOAD=/path/to/libhoard.so
>
> 3) have fun ;)
>
> Rik
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
