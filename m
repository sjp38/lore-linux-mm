content-class: urn:content-classes:message
Subject: RE: broken VM in 2.4.10-pre9
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Date: Mon, 17 Sep 2001 10:40:45 -0500
Message-ID: <878A2048A35CD141AD5FC92C6B776E4907BB98@xchgind02.nsisw.com>
From: "Rob Fuller" <rfuller@nsisoftware.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>, "Eric W. Biederman" <ebiederm@xmission.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

One argument for reverse mappings is distributed shared memory or
distributed file systems and their interaction with memory mapped files.
For example, a distributed file system may need to invalidate a specific
page of a file that may be mapped multiple times on a node.

This may be a naive argument given my limited knowledge of Linux memory
management internals.  If so, I will refrain from posting this sort of
thing in the future.  Let me know.

> -----Original Message-----
> From: Rik van Riel [mailto:riel@conectiva.com.br]
> Sent: Monday, September 17, 2001 7:13 AM
> To: Eric W. Biederman
> Cc: linux-kernel@vger.kernel.org; linux-mm@kvack.org
> Subject: Re: broken VM in 2.4.10-pre9
> 
> 
> On 17 Sep 2001, Eric W. Biederman wrote:

<snip>

> > Do you have any arguments for the reverse mappings or just 
> for some of
> > the other side effects that go along with them?
> 
> Mainly for the side effects, but until somebody comes
> up with another idea to achieve all the side effects I'm
> not giving up on reverse mappings. If you can achieve
> all the good stuff in another way, show it.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
