Subject: Re: 2.5.65-mm3 bad: scheduling while atomic! [SCSI]
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
In-Reply-To: <87el4z1sq3.fsf@lapper.ihatent.com>
References: <20030320235821.1e4ff308.akpm@digeo.com>
	 <87el4z1sq3.fsf@lapper.ihatent.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Message-Id: <1048344561.8912.2.camel@irongate.swansea.linux.org.uk>
Mime-Version: 1.0
Date: 22 Mar 2003 14:49:21 +0000
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexander Hoogerhuis <alexh@ihatent.com>
Cc: Andrew Morton <akpm@digeo.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 2003-03-22 at 12:38, Alexander Hoogerhuis wrote:
> Andrew Morton <akpm@digeo.com> writes:
> > 
> > [SNIP]
> > 
> 
> Here's a few more funnies caught while burning a CD:

ide-scsi is known broken in 2.5, and will stay that way for a little
while yet I suspect. I sent Linus the infrastructure needed to fix
it yesterday.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
