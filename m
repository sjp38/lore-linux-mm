Message-ID: <39D9EF24.491F4389@SANgate.com>
Date: Tue, 03 Oct 2000 17:37:24 +0300
From: BenHanokh Gabriel <gabriel@SANgate.com>
MIME-Version: 1.0
Subject: kiobuf questions
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

hi

i'm trying to understand the role of the kiobuf struct in the io
subsystem.

there are 2 fields i failed to see any reference to :
end_io  and
wait_queue 

now, the documentation says that this is a completion callback , but i
never saw anyone using it.

the same goes for the wait_queue, i didn't see any code utilizing it(
except for the kiobuf_wait_for_io() which noone uses )

THX
/gabi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
