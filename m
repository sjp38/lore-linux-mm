From: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Message-Id: <200008080554.WAA19987@google.engr.sgi.com>
Subject: Re: RFC: design for new VM
Date: Mon, 7 Aug 2000 22:54:43 -0700 (PDT)
In-Reply-To: <20000807202640.A12492@archimedes.suse.com> from "David Gould" at Aug 07, 2000 08:26:40 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Gould <dg@suse.com>
Cc: Gerrit.Huizenga@us.ibm.com, Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

> 
> Hmmm, the vm discussion and the lack of good documentation on vm systems
> has sent me back to reread my old "VMS Internals and Data Structures" book,

I have been stressing the importance of documenting what people do
under Documentation/vm/*. Thinking I would provide an example, I 
created two new files there, at least one of which was quickly outdated
by related changes ...

It would probably help documentation if Linus asked for that along
with patches which considerably change current algorithms. Trust me,
I have had to go back and look at documentations three weeks after
I submitted a patch ... thats all it takes to forget why something
was done one way, rather than another ...

Kanoj
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
