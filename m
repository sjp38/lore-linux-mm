Received: from stingray.netplus.net (root@stingray.netplus.net [206.250.192.19])
	by kvack.org (8.8.7/8.8.7) with ESMTP id TAA15725
	for <linux-mm@kvack.org>; Sat, 9 Jan 1999 19:31:58 -0500
Message-ID: <3697F442.222A2301@netplus.net>
Date: Sat, 09 Jan 1999 18:28:50 -0600
From: Steve Bergman <steve@netplus.net>
MIME-Version: 1.0
Subject: Re: Results: pre6 vs pre6+zlatko's_patch  vs pre5 vs arcavm13
References: <Pine.LNX.3.96.990107001448.1242B-100000@laser.bogus> <36942ACA.3F8C055D@netplus.net> <3697DA94.F0F32F70@netplus.net>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Ben McCann <bmccann@indusriver.com>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, Linus Torvalds <torvalds@transmeta.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Steve Bergman wrote:

I ran the "image test" (loading 116 jpg images simultaneously) on the latest
patches and got these results in 128MB (I end up with ~ 160MB in swap):

pre6+zlatko's_patch	2:35
pre6			2:27
pre5			1:58
arcavm13		9:13

Arcavm13 (the star performer in the low memory test) is having problems here. 
Pre5, which I performed about the same as the others in the my low memory test
and which I ignored in my even lower 12MB test looks quite good here.  Based on
it's good performance here, I decided to run the 12MB kernel compile test on it,
as well.  (See what happens when I try to cut corners...)

In 12MB:

pre6+zlatko_patch       22:14   383206  204482  57823
pre6                    20:54   352934  191210  48678
pre5                    19:35	334680	183732	93427 
arcavm13                19:45   344452  180243  38977

Pre5 is looking good.  Based upon the tests that I have run, anyway.  I agree
with the person who expressed a distrust of benchmarks.  But numbers are
necessary for tuning.  "Feels faster" is just not a very trustworthy thing.  So
I also agree with one of the responses:

"Try out your favorite apps and time some portion of them and post any
interesting numbers." (paraphrased)

Benchmarks are not the problem.  The problem is the lack of comprehensiveness,
or the tunnel-vision if you prefer, that benchmarks can lead one into.  Find a
way to quantify the things that you do everyday and post the results.

-Thanks
-Steve
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
