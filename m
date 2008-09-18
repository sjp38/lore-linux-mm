Message-ID: <48D29AFB.5070409@linux-foundation.org>
Date: Thu, 18 Sep 2008 13:16:27 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: Populating multiple ptes at fault time
References: <48D142B2.3040607@goop.org> <48D1625C.7000309@redhat.com> <48D17A93.4000803@goop.org>
In-Reply-To: <48D17A93.4000803@goop.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Chris Snook <csnook@redhat.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Hugh Dickens <hugh@veritas.com>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Avi Kivity <avi@qumranet.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

I had a patch like that a couple of years back but it was not accepted.

http://www.kernel.org/pub/linux/kernel/people/christoph/prefault/

http://readlist.com/lists/vger.kernel.org/linux-kernel/14/70942.html

http://www.ussg.iu.edu/hypermail/linux/kernel/0503.1/1292.html


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
