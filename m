From: James A. Sutherland <jas88@cam.ac.uk>
Subject: Re: suspend processes at load (was Re: a simple OOM ...) 
Date: Thu, 19 Apr 2001 21:06:27 +0100
Message-ID: <ilgudtkrv54ef9lrq5t2af4co78vpam861@4ax.com>
References: <15790000.987706428@baldur> <Pine.LNX.4.33.0104191609500.17635-100000@duckman.distro.conectiva>
In-Reply-To: <Pine.LNX.4.33.0104191609500.17635-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Dave McCracken <dmc@austin.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 19 Apr 2001 16:13:02 -0300 (BRST), you wrote:

>On Thu, 19 Apr 2001, Dave McCracken wrote:
>> --On Thursday, April 19, 2001 19:47:12 +0100 "James A. Sutherland"
>> <jas88@cam.ac.uk> wrote:
>>
>> > Well, it was my proposal when I first said it :-)
>>
>> Oops.  My apologies.  I'd lost track of whose idea it was originally :)
>
>Actually, this idea must have been in Unix since about
>Bell Labs v5 Unix, possibly before.

Well, good to know our wheel's the same shape as everyone else's :-)

>And when paging was introduced in 3bsd, process suspension
>under heavy load was preserved in the system to make sure
>the system would continue to make progress under heavy
>load instead of thrashing to a halt.
>
>This is not a new idea, it's an old solution to an old
>problem; it even seems to work quite well.
>
>Incidentally, the "minimal working set" idea Stephen posted
>was also in 3bsd. Since this idea is good for preserving the
>forward progress of smaller programs and is extremely simple
>to implement, we probably want this too.

Yes. A quick look at how VMS/WinNT implements this strategy might be
useful here too; still a good idea, even if MS have assimilated it :-)


James.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
