Subject: Re: running 2.4.2 kernel under 4MB Ram
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
In-Reply-To: <1035312869.2209.30.camel@amol.in.ishoni.com>
References: <1035312869.2209.30.camel@amol.in.ishoni.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 22 Oct 2002 11:06:43 +0100
Message-Id: <1035281203.31873.34.camel@irongate.swansea.linux.org.uk>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Amol Kumar Lad <amolk@ishoni.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2002-10-22 at 19:54, Amol Kumar Lad wrote:
> Hi,
>  I want to run 2.4.2 kernel on my embedded system that has only 4 Mb
> SDRAM . Is it possible ?? Is there any constraint for the minimum SDRAM
> requirement for linux 2.4.2

You want to run something a lot newer than 2.4.2. 2.4.19 will run on a
4Mb box, and with Rik's rmap vm seems to be run better than 2.2. That
will depend on the workload.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
