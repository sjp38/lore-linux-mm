Received: by wr-out-0506.google.com with SMTP id 57so1593683wri
        for <linux-mm@kvack.org>; Mon, 30 Apr 2007 18:23:30 -0700 (PDT)
Message-ID: <a36005b50704301823w6a0c4b2fsacb0161d4a9eec73@mail.gmail.com>
Date: Mon, 30 Apr 2007 18:23:29 -0700
From: "Ulrich Drepper" <drepper@gmail.com>
Subject: Re: MADV_FREE functionality
In-Reply-To: <46368FAA.3080104@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070430162007.ad46e153.akpm@linux-foundation.org>
	 <46368FAA.3080104@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/30/07, Rik van Riel <riel@redhat.com> wrote:
> Andrew Morton wrote:
> > Because right now, I don't know where we are with respect to these things and
> > I doubt if many of our users know either.  How can Michael write a manpage for
> > this is we don't tell him what it all does?

I think we've been very clear before and Rik's description here puts
it all nicely in one place.  If you're worried about semantics you can
rest assured, it is all sound.  If this is what is holding up the
patch then add it to your collection.  Only if you have technical
objections should you hold it off.  The patch makes sense (and has
been validated by being implemented in the same way on other OSes) and
it is really needed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
