Subject: Re: running 2.4.2 kernel under 4MB Ram
From: Amol Kumar Lad <amolk@ishoni.com>
In-Reply-To: <1035281203.31873.34.camel@irongate.swansea.linux.org.uk>
References: <1035281203.31873.34.camel@irongate.swansea.linux.org.uk>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 22 Oct 2002 20:31:43 -0400
Message-Id: <1035333109.2200.2.camel@amol.in.ishoni.com>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

It means that I _cannot_ run 2.4.2 on a 4MB box. 
Actually my embedded system already has 2.4.2 running on a 16Mb. I was
looking for a way to run it in 4Mb. 
So Is upgrade to 2.4.19 the only option ??

-- Amol


On Tue, 2002-10-22 at 06:06, Alan Cox wrote:
> On Tue, 2002-10-22 at 19:54, Amol Kumar Lad wrote:
> > Hi,
> >  I want to run 2.4.2 kernel on my embedded system that has only 4 Mb
> > SDRAM . Is it possible ?? Is there any constraint for the minimum
> SDRAM
> > requirement for linux 2.4.2
> 
> You want to run something a lot newer than 2.4.2. 2.4.19 will run on a
> 4Mb box, and with Rik's rmap vm seems to be run better than 2.2. That
> will depend on the workload.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
