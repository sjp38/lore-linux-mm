Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id KAA30806
	for <linux-mm@kvack.org>; Wed, 20 Jan 1999 10:30:10 -0500
Date: Wed, 20 Jan 1999 16:25:21 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Reply-To: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: arca-vm-26
In-Reply-To: <Pine.LNX.3.96.990120011948.7203C-100000@laser.bogus>
Message-ID: <Pine.LNX.3.96.990120162138.4544A-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
Cc: Nimrod Zimerman <zimerman@deskmail.com>, John Alvord <jalvo@cloud9.net>, "Stephen C. Tweedie" <sct@redhat.com>, Steve Bergman <steve@netplus.net>, dlux@dlux.sch.bme.hu, "Nicholas J. Leon" <nicholas@binary9.net>, Kalle Andersson <kalle@sslug.dk>, Heinz Mauelshagen <mauelsha@ez-darmstadt.telekom.de>, Ben McCann <bmccann@indusriver.com>
List-ID: <linux-mm.kvack.org>

On Wed, 20 Jan 1999, Andrea Arcangeli wrote:

> I've put out an arca-vm-26. The differences between arca-vm-25 and -26 are

I've released now arca-vm-27. I would like to know if you see
some difference between arca-vm-26 and -27. The main difference is that I
removed again the swapout smart code (that I inserted at PG_dirty time
trying to decrease the stalls caused by the swap code that was running
too much).

ftp://e-mind.com/pub/linux/kernel-patches/2.2.0-pre8testing-arca-VM-27.gz

Thanks.

Andrea Arcangeli

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
