Received: from gatekeeper.tait.co.nz (localhost.localdomain [127.0.0.1])
	by gatekeeper.tait.co.nz (8.11.2/8.9.3) with ESMTP id g84LweH05958
	for <linux-mm@kvack.org>; Thu, 5 Sep 2002 09:58:40 +1200
Received: from sunstorm.tait.co.nz (sunstorm.tait.co.nz [172.25.40.9])
	by gatekeeper.tait.co.nz (8.11.2/8.9.3) with ESMTP id g84LweL05952
	for <linux-mm@kvack.org>; Thu, 5 Sep 2002 09:58:40 +1200
Received: from parore (parore.tait.co.nz [172.25.140.12])
 by sunstorm.tait.co.nz (iPlanet Messaging Server 5.1 (built May  7 2001))
 with ESMTP id <0H1X005Q5P1SC9@sunstorm.tait.co.nz> for linux-mm@kvack.org;
 Thu, 05 Sep 2002 09:58:40 +1200 (NZST)
Date: Thu, 05 Sep 2002 09:58:40 +1200 (NZST)
From: John Carter <john.carter@tait.co.nz>
Subject: Helping the Programmer's help themselves...
Message-id: <Pine.LNX.4.44.0209050945100.4437-100000@parore>
MIME-version: 1.0
Content-type: TEXT/PLAIN; charset=US-ASCII
Content-transfer-encoding: 7BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

One major problem with all the OOM handling ideas are they are hostile. 

They assume the situation is out of control and desperate.

What the programmers need is help to avoid getting the user into such dire 
straits. Consider two scenarios....

    * Nibbled to Death by Ducks. The program is malloc'ing many tiny
      chunks of memory. Eventually it starts thrashing. A quarter of
      an hour later it runs out of memory and malloc returns 0 or some
      friendly OOM killer hits it on the head. 

      Assume the OOM killer doesn't, what can the programmer do? Pop
      up a friendly dialog box, and shutdown neatly? Nah! Not enough
      memory to do that!

    * Grabbing a Large Chunk. I was using Ghost View. For various
      reasons it asked for a huge amount of memory. Malloc didn't
      return zero, there was enough swap. However, the system turned
      to sticky mud and stayed that way until I could kill the X
      server 15 minutes later...

Now assume that these two programs are written by responsible, caring 
programmers. What could they have done to stop entering this domain? 

Nothing. The OS hates users. ;-)

The first "Nibbled To Death by Ducks" scenario could be resolved by a
"memory low, system getting slow" signal.

Now if the OS had a "memory getting low, system getting slow" signal,
and could send that signal to all programs, _before_ things got
desperate. Then the programmer could start bailing out in a clean
and friendly manner. 

Most programs, such as the X server would just ignore it. However a
well behaved memory intensive non-critical program would respond by,
pausing, presenting a modal "Memory Low. Do you want me to die, or
continue?" dialog. 

On recieving the inverse signal, "memory fine, system go" signal the
dialog box would go away and things would continue. Some fuzzy
heuristics would be needed to tide the system over transient
fluctuations.

The "Grabbing a Large Chunk" scenario could be resolved by a
"friendly, caring malloc".

If the OS had a "malloc, but not at the cost of the system" malloc,
then as any programmer knows when he is going to be grabbing a really
large chunk, he can use that. 

So when he grabs a large chunk he uses the "friendly caring malloc"
and checks the return code. If the answer is bad, he pops up a
friendly message that tells the user that he really doesn't want to do
that and why. The user may at his own choice and peril say "do so
anyway".

I'm sure the friendly caring malloc could be written in userland, any 
hints on how?

The "memory getting low, system getting slow" signals would probably
need some OS support, but perhaps could be fudged by a userland daemon.

-- 


John Carter                             Phone : (64)(3) 358 6639
Tait Electronics                        Fax   : (64)(3) 359 4632
PO Box 1645 Christchurch                Email : john.carter@tait.co.nz
New Zealand

Good Ideas:
Ruby                 - http://www.ruby-lang-org - The best of perl,python,scheme without the pain.
Valgrind             - http://developer.kde.org/~sewardj/ - memory debugger for x86-GNU/Linux
Free your books      - http://www.bookcrossing.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
