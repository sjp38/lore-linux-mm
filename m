Subject: Re: Atomic operation for physically moving a page
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20040619003712.35865.qmail@web10904.mail.yahoo.com>
References: <20040619003712.35865.qmail@web10904.mail.yahoo.com>
Content-Type: text/plain
Message-Id: <1087613018.4921.29.camel@nighthawk>
Mime-Version: 1.0
Date: Fri, 18 Jun 2004 19:43:38 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ashwin Rao <ashwin_s_rao@yahoo.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2004-06-18 at 17:37, Ashwin Rao wrote:
> I want to copy a page from one physical location to
> another (taking the appr. locks). To keep the
> operation of copying and updation of all ptes and
> caches atomic one way proposed by my team members was
> to sleep the processes accessing the page.

How do you make sure that no more processes begin to access the page
while you're doing your work?

BTW, look at the swap code :)

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
