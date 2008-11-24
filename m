Date: Mon, 24 Nov 2008 11:24:43 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH][V2] Make get_user_pages interruptible
Message-Id: <20081124112443.5a2e0885.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0811241859160.3700@blonde.site>
References: <604427e00811211605j20fd00bby1bac86b4cc3c380b@mail.gmail.com>
	<alpine.DEB.2.00.0811211618160.20523@chino.kir.corp.google.com>
	<6599ad830811211818g5ade68cua396713be94f80dc@mail.gmail.com>
	<alpine.DEB.2.00.0811220152300.18236@chino.kir.corp.google.com>
	<604427e00811240938n5eca39cetb37b4a63f20a0854@mail.gmail.com>
	<Pine.LNX.4.64.0811241859160.3700@blonde.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: yinghan@google.com, rientjes@google.com, menage@google.com, linux-mm@kvack.org, rohitseth@google.com, riel@redhat.com, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Mon, 24 Nov 2008 19:15:16 +0000 (GMT)
Hugh Dickins <hugh@veritas.com> wrote:

> The linux-mm list has a tiresome habit of removing one line at the top.
> 
> For a year or so I used to wonder why Christoph Lameter sent so many
> empty messages in response to patches: at last I realized he was
> sending a single-line Acked-by: which linux-mm kindly removed.
> 
> I grow tired of it, but forget who to report it to: Rik is sure to know.

Benjamin LaHaise <bcrl@kvack.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
