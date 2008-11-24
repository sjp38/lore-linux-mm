Date: Mon, 24 Nov 2008 21:33:13 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH][V2] Make get_user_pages interruptible
In-Reply-To: <20081124210436.GA13536@kvack.org>
Message-ID: <Pine.LNX.4.64.0811242132010.11588@blonde.site>
References: <604427e00811211605j20fd00bby1bac86b4cc3c380b@mail.gmail.com>
 <alpine.DEB.2.00.0811211618160.20523@chino.kir.corp.google.com>
 <6599ad830811211818g5ade68cua396713be94f80dc@mail.gmail.com>
 <alpine.DEB.2.00.0811220152300.18236@chino.kir.corp.google.com>
 <604427e00811240938n5eca39cetb37b4a63f20a0854@mail.gmail.com>
 <Pine.LNX.4.64.0811241859160.3700@blonde.site> <Pine.LNX.4.64.0811241933130.9595@blonde.site>
 <20081124202847.GS22491@kvack.org> <492B12A0.80209@oracle.com>
 <20081124210436.GA13536@kvack.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin LaHaise <bcrl@kvack.org>
Cc: Randy Dunlap <randy.dunlap@oracle.com>, Ying Han <yinghan@google.com>, David Rientjes <rientjes@google.com>, Paul Menage <menage@google.com>, linux-mm@kvack.org, akpm <akpm@linux-foundation.org>, Rohit Seth <rohitseth@google.com>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Great: thanks a lot, Ben.  (And excuse my top-posting in this case.)

On Mon, 24 Nov 2008, Benjamin LaHaise wrote:
> It should be fixed now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
