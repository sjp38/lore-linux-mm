Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 0F8F76B0062
	for <linux-mm@kvack.org>; Wed, 31 Oct 2012 14:45:08 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fa10so1296811pad.14
        for <linux-mm@kvack.org>; Wed, 31 Oct 2012 11:45:07 -0700 (PDT)
Date: Wed, 31 Oct 2012 11:45:04 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: zram OOM behavior
In-Reply-To: <CAA25o9RoJ7OCNkXiJHAR3edtE8VjN8dWx7AKF7oBU9rxUja0KQ@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1210311144340.8809@chino.kir.corp.google.com>
References: <20121015144412.GA2173@barrios> <CAA25o9R5OYSMZ=Rs2qy9rPk3U9yaGLLXVB60Yncqvmf3Y_Xbvg@mail.gmail.com> <CAA25o9QcaqMsYV-Z6zTyKdXXwtCHCAV_riYv+Bhtv2RW0niJHQ@mail.gmail.com> <20121022235321.GK13817@bbox> <alpine.DEB.2.00.1210222257580.22198@chino.kir.corp.google.com>
 <CAA25o9ScWUsRr2ziqiEt9U9UvuMuYim+tNpPCyN88Qr53uGhVQ@mail.gmail.com> <alpine.DEB.2.00.1210291158510.10845@chino.kir.corp.google.com> <CAA25o9Rk_C=jaHJwWQ8TJL0NF5_Xv2umwxirtdugF6w3rHruXg@mail.gmail.com> <20121030001809.GL15767@bbox>
 <CAA25o9R0zgW74NRGyZZHy4cFbfuVEmHWVC=4O7SuUjywN+Uvpw@mail.gmail.com> <alpine.DEB.2.00.1210292239290.13203@chino.kir.corp.google.com> <CAA25o9Tp5J6-9JzwEfcZJ4dHQCEKV9_GYO0ZQ05Ttc3QWP=5_Q@mail.gmail.com> <CAA25o9SE353h9xjUR0ste3af1XPuyL_hieGBUWqmt_S5hCn_9A@mail.gmail.com>
 <alpine.DEB.2.00.1210302142510.26588@chino.kir.corp.google.com> <CAA25o9RLNeDCKw7M7qQKs_L_+u+yti1KkLH4WU2PQ3cgRekuGA@mail.gmail.com> <CAA25o9RoJ7OCNkXiJHAR3edtE8VjN8dWx7AKF7oBU9rxUja0KQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luigi Semenzato <semenzato@google.com>
Cc: Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, Dan Magenheimer <dan.magenheimer@oracle.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Sonny Rao <sonnyrao@google.com>

On Tue, 30 Oct 2012, Luigi Semenzato wrote:

> To make it clear, I am suggesting that this "fix" might work as a
> temporary workaround until a better fix is available.
> 

A temporary workaround is to do a kill -9 of the hung process since even 
the 3.4 oom killer will automatically give it access to memory reserves.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
