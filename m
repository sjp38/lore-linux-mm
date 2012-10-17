Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 3E4C76B002B
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 23:18:49 -0400 (EDT)
Message-ID: <COL115-DS10E0F88BEBFBB5F189B1D6BC770@phx.gbl>
From: "Jun Hu" <duanshuidao@hotmail.com>
References: <COL115-DS17FCFB8683288781F8E011BC770@phx.gbl> <CAHGf_=p__OFKsP=qf+RP28gZntYAwzq-gNnQ61UR_kJuFL7OSw@mail.gmail.com>
In-Reply-To: <CAHGf_=p__OFKsP=qf+RP28gZntYAwzq-gNnQ61UR_kJuFL7OSw@mail.gmail.com>
Subject: Re: [help] kernel boot parameter "mem=xx" disparity
Date: Wed, 17 Oct 2012 11:18:42 +0800
MIME-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="utf-8";
	reply-type=original
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>

Yes, I  understand now,  through google "memory hole" ; thanks a lot.

recent regular machine often have  ~1G hole. It  is  true.

I found  from boot msg:

55:<6>[    0.000000] Memory: 4171008k/5242880k available (4404k kernel code, 
788584k absent, 283288k reserved, 7685k data, 1340k init)

it tells me where 1G memory went .



-----a??a??e?(R)a>>?----- 
From: KOSAKI Motohiro
Sent: Wednesday, October 17, 2012 9:43 AM
To: Jun Hu
Cc: linux-mm
Subject: Re: [help] kernel boot parameter "mem=xx" disparity

On Tue, Oct 16, 2012 at 8:55 PM, Jun Hu <duanshuidao@hotmail.com> wrote:
> Hi Guys:
>
> My machine has 8G memory, when I use kernel boot parameter mem=5G , it 
> only
> display a??4084 Ma?? using a??free a??m a??.
> where the a??5120-4084 = 1036M a?? memory run?

mem is misleading parameter. It is not specify amount memoy. It is specify
maximum recognized address. Thus when your machine have some memory
hole, you see such result. Don't worry, recent regular machine often have
~1G hole.

Detailed memory map is logged in /var/log/messages as a part of boot 
messages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=ilto:"dont@kvack.org"> email@kvack.org </a> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
