Received: from stingray.netplus.net (root@stingray.netplus.net [206.250.192.19])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA15093
	for <linux-mm@kvack.org>; Sat, 9 Jan 1999 17:41:52 -0500
Message-ID: <3697DA94.F0F32F70@netplus.net>
Date: Sat, 09 Jan 1999 16:39:16 -0600
From: Steve Bergman <steve@netplus.net>
MIME-Version: 1.0
Subject: Results: pre6 vs pre6+zlatko's_patch  vs pre5 vs arcavm13
References: <Pine.LNX.3.96.990107001448.1242B-100000@laser.bogus> <36942ACA.3F8C055D@netplus.net>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Ben McCann <bmccann@indusriver.com>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, Linus Torvalds <torvalds@transmeta.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

In an effort to streamline testing, I am now running just:

make depend; make clean; make bzlilo

and leaving out the modules part.  I am also compiling only a minimal kernel
with no options at all selected in menuconfig.  I have added an idle mysql
server to the mix, which still includes netscape and a number of the usual
daemons (sendmail, lpd, inetd, etc.) along with vmstat 1, top, and ping
remote_host.  Please remember Linus' caution about the "swaps" number.  Here are
the latest results:

In 16MB:

pre6+zlatko_patch	5:29	192527	149728	3554
pre6			5:27	192002	149694	4257
pre5			5:28	188566	148674	5646
arcavm13		5:32	188560	148234	1594

Really putting on the squeeze, I tried out mem=12M which forced about 24MB into
the swap area.

In 12MB:

pre6+zlatko_patch	22:14	383206	204482	57823
pre6			20:54	352934	191210	48678
pre5			Did not test
arcavm13		19:45	344452	180243	38977


They all seem about the same in 16MB.  arcavm13 looks good in 12MB.  Zlatko, let
me know if you have any specific tests you want me to run on your patch.

-Steve
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
