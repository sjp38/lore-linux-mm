Subject: Re: [PATCH] Remove nr_async_pages limit
Date: Mon, 4 Jun 2001 07:39:10 +0100 (BST)
In-Reply-To: <874rtxoidx.fsf@atlas.iskon.hr> from "Zlatko Calusic" at Jun 03, 2001 02:30:34 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <E156o18-00059a-00@the-village.bc.nu>
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: zlatko.calusic@iskon.hr
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> This patch removes the limit on the number of async pages in the
> flight.

I have this in all  2.4.5-ac. It does help a little but there are some other
bits you have to deal with too, in paticular wrong aging. See the -ac version
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
