Received: from tltsu.anu.edu.au (yanchep.anu.edu.au [150.203.141.24])
	by coorong.anu.edu.au (8.9.3/8.9.3) with ESMTP id UAA10559
	for <Linux-MM@kvack.org>; Thu, 25 May 2000 20:05:56 +1000 (EST)
Message-ID: <392CFA97.F7F298A5@tltsu.anu.edu.au>
Date: Thu, 25 May 2000 20:04:07 +1000
From: Robert Cohen <robert@coorong.anu.edu.au>
MIME-Version: 1.0
Subject: [Fwd: Can Linux learn from the Solaris VM system]
Content-Type: multipart/mixed;
 boundary="------------74571087DF21F653A2A9C551"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux-MM@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------74571087DF21F653A2A9C551
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

I recently posted this to the linux -kernel list, but thought it might be
of interest here.
I dont read the MM list, so please CC any replies to me?



Robert Cohen wrote:

> Heres a short description of features added to the Solaris VM system
> recently
> http://sunsolve.Sun.COM/pub-cgi/show.pl?target=content/content8.
> I thought one of the people working on the Linux VM might be able to get
> some ideas from it.
> It talks about what Solaris does to stop cached file system data from
> treading on cached executables.
> Although it is rather short on details.
> Or do we already have systems in place to deal with this kind of
> problem?
>
> Robert Cohen

--------------74571087DF21F653A2A9C551
Content-Type: message/rfc822
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

X-Mozilla-Status2: 00000000
Message-ID: <3921EF84.10706F45@coorong.anu.edu.au>
Date: Wed, 17 May 2000 11:01:56 +1000
From: Robert Cohen <robert@coorong.anu.edu.au>
X-Mailer: Mozilla 4.51 [en] (X11; I; SunOS 5.7 sun4u)
X-Accept-Language: en
MIME-Version: 1.0
To: linux-kernel@vger.rutgers.edu
Subject: Can Linux learn from the Solaris VM system
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Heres a short description of features added to the Solaris VM system
recently
http://sunsolve.Sun.COM/pub-cgi/show.pl?target=content/content8.
I thought one of the people working on the Linux VM might be able to get
some ideas from it.
It talks about what Solaris does to stop cached file system data from
treading on cached executables.
Although it is rather short on details.
Or do we already have systems in place to deal with this kind of
problem?

Robert Cohen



--------------74571087DF21F653A2A9C551--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
