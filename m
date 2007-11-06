Received: by nz-out-0506.google.com with SMTP id s1so4165423nze
        for <linux-mm@kvack.org>; Tue, 06 Nov 2007 13:27:30 -0800 (PST)
Message-ID: <cfd9edbf0711061327q4d43c2c3h3c22e71c143084b6@mail.gmail.com>
Date: Tue, 6 Nov 2007 22:27:29 +0100
From: "=?ISO-8859-1?Q?Daniel_Sp=E5ng?=" <daniel.spang@gmail.com>
Subject: Re: [RFC Patch] Thrashing notification
In-Reply-To: <20071106150152.3ba1e4cc@bree.surriel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <op.t1bp13jkk4ild9@bingo> <20071105183025.GA4984@dmt>
	 <20071105151723.71b3faaf@bree.surriel.com>
	 <cfd9edbf0711060241i7ad7e058m3e6795d90c4da82b@mail.gmail.com>
	 <20071106150152.3ba1e4cc@bree.surriel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Marcelo Tosatti <marcelo@kvack.org>, linux-mm@kvack.org, drepper@redhat.com, akpm@linux-foundation.org, mbligh@mbligh.org, balbir@linux.vnet.ibm.com, 7eggert@gmx.de
List-ID: <linux-mm.kvack.org>

On 11/6/07, Rik van Riel <riel@redhat.com> wrote:
> To get out of the "my patch is better" line of conversation,
> I guess you and Marcelo should probably try to figure out
> some threshold that you both agree on.

Sure, we will do that. =)

> > A concern, or feature =), with the notify-on-swap method is that with
> > responsive user applications, it will never use swap at all. There are
> > for sure systems where this behavior is desirable, but for example
> > desktop systems, the memory occupied by inactive processes might be
> > better used by active ones.
>
> Well, if the inactive processes get woken up by the low memory
> notification and free some of their memory, the active processes
> will use the memory from the inactive ones :)

Yes, but it will probably take some time before all applications start
to use this and even if they do, we might have to consider the case
where the limit is reached and applications have no more memory to
spare.

Also if applications are swamped with notifications we might found our
self in a new new kind of thrashing state where dumb applications
(e.g., my test application) repeatedly and unsuccessfully tries to
release memory. So instead of notify on each priority threshold reach
or every interval where swap has occurred we could enter a state and
not leave it until memory pressure have decreased and only notify on
state change.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
