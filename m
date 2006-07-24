Subject: Re: [PATCH] Add maintainer for memory management
From: Steven Rostedt <rostedt@goodmis.org>
In-Reply-To: <1153749795.23798.19.camel@lappy>
References: <1153713707.4002.43.camel@localhost.localdomain>
	 <1153749795.23798.19.camel@lappy>
Content-Type: text/plain
Date: Mon, 24 Jul 2006 10:25:08 -0400
Message-Id: <1153751108.4002.104.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@osdl.org>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2006-07-24 at 16:03 +0200, Peter Zijlstra wrote:
> Hi Steven,
> 
> The way I understand the maintainership of the memory management code is
> as follows: there is explicitly no maintainer listed. This code is so
> sensitive and has interactions with so many other sub-systems that it
> would not be doable to look at it from all possible angles by only one
> person.
> 
> As it stands its more a group of people headed by Linus, Andrew and
> Hugh.
> 

Thanks Peter for the explanation.

So, I'll send another patch to just add the linux-mm mailing list, since
that should have no qualms about it.

Thanks,

-- Steve 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
