From: Bryan Paxton <evil7@seifried.org>
Reply-To: evil7@seifried.org
Subject: 24t1ac7-classzone-31
Date: Sun, 4 Jun 2000 15:08:05 -0500
Content-Type: text/plain
References: <Pine.LNX.4.21.0006041158560.1855-100000@inspiron.random>
In-Reply-To: <Pine.LNX.4.21.0006041158560.1855-100000@inspiron.random>
MIME-Version: 1.0
Message-Id: <00060415160900.00638@sQa.speedbros.org>
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ok I ran the same tests..... LA peaked at 2.28, though the perfomance felt
pretty stable... I noticed a lot less swapping(only 300K) which is fine and the
swapping performance was better(swapped apps in and out faster and better), but
the overall system performance and response was less than kswapdtune...
I think if you and Rik work closely on this 2.4.0 is gonna have a nice VM when
it's released : )


On Sun, 04 Jun 2000, you wrote:
> On Sat, 3 Jun 2000, THE INFAMOUS wrote:
> 
> >Did a usual stress test :
> >
> >
> >X + gnome + sawfish + 3 Eterms + balsa + netscape + cp -af
> >          /usr/src/linux /somewhere + updatedb 
> >
> >The overall performance is indeed better.... I was able to still move around
> >under all that load, only saw a peak in the LA of 1.45 and recovered nicely to
> >0.0.8(after cp and updatedb were done). 
> 
> What happens if you try again the same with 2.4.0-test1-ac7+classzone-31?
> 
> Andrea
-- 
Bryan Paxton

"I don't need to sleep or eat, I'll smoke a thousand cigarettes."
- Sebadoh


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
