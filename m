Subject: Re: [RFC] [RFT] Shared /dev/zero mmaping feature
References: <200003081751.JAA42578@google.engr.sgi.com>
From: Christoph Rohland <hans-christoph.rohland@sap.com>
Date: 08 Mar 2000 19:35:24 +0100
Message-ID: <qwwya7tnwcz.fsf@sap.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org, Ingo Molnar <mingo@chiara.csoma.elte.hu>
List-ID: <linux-mm.kvack.org>

kanoj@google.engr.sgi.com (Kanoj Sarcar) writes:

> I am not sure why you think the /dev/zero code is a workaround on
> top of shm. A lot of code and mechanisms are easily sharable between
> shm and /dev/zero, since they are, as I pointed out, anonymous
> shared pages. The only differences are when the data structures are
> torn down, and which processes may attach to the segments.

Because I think the current shm code should be redone in a way that
shared anonymous pages live in the swap cache. You could say the shm
code is a workaround :-)

> Btw, implementing /dev/zero using shm code mostly is _quite_ easy,
> that's how the code has been since 2.3.48. Even integrating with
> shmfs has been pretty easy, as you have seen in the patches I have
> CCed you on. The harder part is to look towards the future and do
> what Linus suggested, namely associate each mapping with an inode so
> in the future the inodecache might possibly be used to manage the
> shm pages. As you know, I sent out a patch for that yesterday.

In my opinion this is one of two orthogonal steps. shm fs targets the
better integration in the file system semantics.

> Its completely okay by me to take in a dev-zero/shmfs integration
> patch that is not perfect wrt /dev/zero, as I have indicated to 
> you and Linus, just so that the shmfs work gets in. I can fix
> minor problems with the /dev/zero code as they come up.
> 
> What sct suggests is quite involved, as he himself mentions. Just
> implementing /dev/zero is probably not a good reason to undertake
> it.

But IMHO reworking shm based on the /dev/zero stuff would be a good
reason to do the /dev/zero stuff right. That's all I wanted to say in
my last mail.

Perhaps I am a little bit too opposed to these changes because I have
seen too many patches thrown on the shm code during the 2.3 cycle
which were plain buggy and nobody cared. Most of my kernel work since
some time is doing quite stupid tests on the shm code.

BTW: I am just running these tests on your patch and it seems to work
quite well. (I will let it run over night) If it survives that I will
also throw some quite complicated /dev/zero tests on it later.

Greetings
		Christoph
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
