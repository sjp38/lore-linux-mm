Subject: Re: hard question re: swap cache
References: <20030527230406.4286.qmail@web41505.mail.yahoo.com>
From: Sean Neakums <sneakums@zork.net>
Date: Wed, 28 May 2003 11:01:56 +0100
In-Reply-To: <20030527230406.4286.qmail@web41505.mail.yahoo.com> (Carl
 Spalletta's message of "Tue, 27 May 2003 16:04:06 -0700 (PDT)")
Message-ID: <6ud6i3o0dn.fsf@zork.zork.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Carl Spalletta <cspalletta@yahoo.com> writes:

> I thought of a simple example. Suppose processes a,b,c have a
> shared, anonymous page.  All processes have this page present.  Then
> the page for a is swapped out.  Then b and c exit unexpectedly,
> after making changes to the page.  When and if 'a' has the page
> swapped back in, what mechanism guarantees that it will see the
> changes made by b and c?

I don't think it makes much sense to say "the page for a" in the case
of a shared page.

-- 
Sean Neakums - <sneakums@zork.net>
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
