Subject: Re: running 2.4.2 kernel under 4MB Ram
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
In-Reply-To: <1035333109.2200.2.camel@amol.in.ishoni.com>
References: <1035281203.31873.34.camel@irongate.swansea.linux.org.uk>
	<1035333109.2200.2.camel@amol.in.ishoni.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 22 Oct 2002 16:39:24 +0100
Message-Id: <1035301164.31917.78.camel@irongate.swansea.linux.org.uk>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Amol Kumar Lad <amolk@ishoni.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2002-10-23 at 01:31, Amol Kumar Lad wrote:
> It means that I _cannot_ run 2.4.2 on a 4MB box. 
> Actually my embedded system already has 2.4.2 running on a 16Mb. I was
> looking for a way to run it in 4Mb. 
> So Is upgrade to 2.4.19 the only option ??

You should move to a later kernel anyway 2.4.2 has a lot of bugs
including some security ones.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
