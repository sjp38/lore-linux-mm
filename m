Date: Sun, 24 Jun 2007 06:23:45 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: vm/fs meetup in september?
Message-ID: <20070624042345.GB20033@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

I'd just like to take the chance also to ask about a VM/FS meetup some
time around kernel summit (maybe take a big of time during UKUUG or so).

I was thinking about trying to arrange a proper mini summit thing, but
it's a bit difficult and we could talk this year about doing it for
subsequent years. If there is a bit of interest, we could probably find
a small room somewhere this year on pretty short notice or do it as a
BOF or something.

I don't want to do it in the VM summit, because that kind of alienates
the filesystem guys. What I want to talk about is anything and everything
that the VM can do better to help the fs and vice versa.  I'd like to
stay away from memory management where not too applicable to the fs.

A few things I'd like to talk about are:

- the address space operations APIs, and their page based nature. I think
  it would be nice to generally move toward offset,length based ones as
  much as possible because it should give more efficiency and flexibility
  in the filesystem.

- write_begin API if it is still an issue by that date. Hope not :)

- truncate races

- fsblock if it hasn't been shot down by then

- how to make complex API changes without having to fix most things
  yourself.


Anyway, if you will be in the area and are interested, let me know (off
list) and we can work out time and place.

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
