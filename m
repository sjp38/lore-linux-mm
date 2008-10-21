Date: Tue, 21 Oct 2008 13:41:33 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC v7][PATCH 2/9] General infrastructure for checkpoint
 restart
Message-Id: <20081021134133.f84151e9.akpm@linux-foundation.org>
In-Reply-To: <20081021202410.GA10423@us.ibm.com>
References: <1224481237-4892-1-git-send-email-orenl@cs.columbia.edu>
	<1224481237-4892-3-git-send-email-orenl@cs.columbia.edu>
	<20081021124130.a002e838.akpm@linux-foundation.org>
	<20081021202410.GA10423@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: orenl@cs.columbia.edu, torvalds@linux-foundation.org, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, tglx@linutronix.de, dave@linux.vnet.ibm.com, mingo@elte.hu, hpa@zytor.com, viro@zeniv.linux.org.uk
List-ID: <linux-mm.kvack.org>

On Tue, 21 Oct 2008 15:24:10 -0500
"Serge E. Hallyn" <serue@us.ibm.com> wrote:

> > I'd like to see the security guys take a real close look at all of
> > this, and for them to do that effectively they should be provided with
> > a full description of the security design of this feature.
> 
> Right, some of the above should be spelled out somewhere.  Should it be
> in the patch description, in the Documentation/checkpoint.txt file,
> or someplace else?

Dupliction is usually bad.  Documentation/checkpoint.txt would be good
(although these things tend to go out of date fast).

If you go that way, please ensure that the documentation patch is early
in the series and that the changelog says "look in here before whining,
dummy".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
