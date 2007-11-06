Date: Tue, 6 Nov 2007 15:01:52 -0500
From: Rik van Riel <riel@redhat.com>
Subject: Re: [RFC Patch] Thrashing notification
Message-ID: <20071106150152.3ba1e4cc@bree.surriel.com>
In-Reply-To: <cfd9edbf0711060241i7ad7e058m3e6795d90c4da82b@mail.gmail.com>
References: <op.t1bp13jkk4ild9@bingo>
	<20071105183025.GA4984@dmt>
	<20071105151723.71b3faaf@bree.surriel.com>
	<cfd9edbf0711060241i7ad7e058m3e6795d90c4da82b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel =?UTF-8?B?U3DDpW5n?= <daniel.spang@gmail.com>
Cc: Marcelo Tosatti <marcelo@kvack.org>, linux-mm@kvack.org, drepper@redhat.com, akpm@linux-foundation.org, mbligh@mbligh.org, balbir@linux.vnet.ibm.com, 7eggert@gmx.de
List-ID: <linux-mm.kvack.org>

On Tue, 6 Nov 2007 11:41:20 +0100
"Daniel SpAJPYng" <daniel.spang@gmail.com> wrote:

> I have actually no problem at all using a device to get the message to
> userspace. My patch was more like a demonstration of when to trigger
> the notification. I still (obviously) think that we need a
> notification for systems without swap too.

I agree.

To get out of the "my patch is better" line of conversation,
I guess you and Marcelo should probably try to figure out
some threshold that you both agree on.

> A concern, or feature =), with the notify-on-swap method is that with
> responsive user applications, it will never use swap at all. There are
> for sure systems where this behavior is desirable, but for example
> desktop systems, the memory occupied by inactive processes might be
> better used by active ones.

Well, if the inactive processes get woken up by the low memory
notification and free some of their memory, the active processes
will use the memory from the inactive ones :)

Not using swap is generally considered a good thing on desktops.

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
