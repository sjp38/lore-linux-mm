Received: by fenrus.demon.nl
	via sendmail from stdin
	id <m13Ubpq-000OX1C@amadeus.home.nl> (Debian Smail3.2.0.102)
	for linux-mm@kvack.org; Thu, 31 Aug 2000 23:25:22 +0200 (CEST)
Message-Id: <m13Ubpq-000OX1C@amadeus.home.nl>
Date: Thu, 31 Aug 2000 23:25:22 +0200 (CEST)
From: arjan@fenrus.demon.nl (Arjan van de Ven)
Subject: Re: [PATCH *] VM patch w/ drop behind for 2.4.0-test8-pre1
In-Reply-To: <Pine.LNX.4.21.0008311801570.7217-100000@duckman.distro.conectiva>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

You wrote:

> - drop_behind(), when we do a readahead, move the pages
>   'behind' us to the inactive list .. this way we can do
>   streaming IO without putting pressure on the working set
> - deactivate pages in generic_file_write(), this does
>   basically the same ... by moving the pages we write to 
>   to the inactive_dirty list, a big download, etc.. doesn't
>   impact the working set of the system

> I'm particularly interested in the impact of streaming IO on
> the performance of the rest of the system with this patch, but
> of course also in the performance of the streaming IO itself.

I must say your enhancements have a very positive effect. 
"dbench 48" results:

test7 plain	35   MB/s
test8p1 riel1	27   MB/s
test8p1 riel2	34.2 MB/s  <-- latest patch

so with this patch the VM approaches test7 behavior _really_ close, but 
with the enhancement in interactive performance!

Greetings,
   Arjan van de Ven
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
