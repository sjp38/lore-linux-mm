Received: from post.mail.demon.net (finch-post-10.mail.demon.net [194.217.242.38])
	by kvack.org (8.8.7/8.8.7) with ESMTP id HAA24914
	for <linux-mm@kvack.org>; Thu, 14 Jan 1999 07:09:20 -0500
Date: Thu, 14 Jan 1999 10:48:11 +0000 (GMT/BST)
From: Mike Jagdis <mike@roan.co.uk>
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
In-Reply-To: <199901131748.RAA06406@dax.scot.redhat.com>
Message-ID: <Pine.LNX.3.91.990114104543.20708B-100000@toaster.roan.co.uk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 13 Jan 1999, Stephen C. Tweedie wrote:

> On Tue, 12 Jan 1999 20:05:21 +0100 (CET), Andrea Arcangeli
> <andrea@e-mind.com> said:
> 
> > Maybe because nobody care about shm? I think shm can wait for 2.3 to be
> > improved.
> 
> "Nobody"?  Oracle uses large shared memory regions for starters.

Yeah, and so does Informix Dynamic Server. But, in general, you
do not want this to be swapped heavily, if at all.

				Mike

-- 
    A train stops at a train station, a bus stops at a bus station.
    On my desk I have a work station...
.----------------------------------------------------------------------.
|  Mike Jagdis                  |  Internet:  mailto:mike@roan.co.uk   |
|  Roan Technology Ltd.         |                                      |
|  54A Peach Street, Wokingham  |  Telephone:  +44 118 989 0403        |
|  RG40 1XG, ENGLAND            |  Fax:        +44 118 989 1195        |
`----------------------------------------------------------------------'

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
