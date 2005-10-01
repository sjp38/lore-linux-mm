Received: by zproxy.gmail.com with SMTP id k1so27023nzf
        for <linux-mm@kvack.org>; Fri, 30 Sep 2005 17:32:02 -0700 (PDT)
Message-ID: <aec7e5c30509301732n1b611d45qb137a14b7b621df8@mail.gmail.com>
Date: Sat, 1 Oct 2005 09:32:02 +0900
From: Magnus Damm <magnus.damm@gmail.com>
Reply-To: Magnus Damm <magnus.damm@gmail.com>
Subject: Re: [PATCH 05/07] i386: sparsemem on pc
In-Reply-To: <1128093929.6145.27.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <20050930073232.10631.63786.sendpatchset@cherry.local>
	 <20050930073258.10631.74982.sendpatchset@cherry.local>
	 <1128093929.6145.27.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Magnus Damm <magnus@valinux.co.jp>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On 10/1/05, Dave Hansen <haveblue@us.ibm.com> wrote:
> On Fri, 2005-09-30 at 16:33 +0900, Magnus Damm wrote:
> > This patch for enables and fixes sparsemem support on i386. This is the
> > same patch that was sent to linux-kernel on September 6:th 2005, but this
> > patch includes up-porting to fit on top of the patches written by Dave Hansen.
>
> I'll post a more comprehensive way to do this in just a moment.
>
>         Subject: memhotplug testing: hack for flat systems

Looks much better, will compile and test on Monday. Thanks.

/ magnus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
