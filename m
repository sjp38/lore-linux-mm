Received: by uproxy.gmail.com with SMTP id e2so813821ugf
        for <linux-mm@kvack.org>; Tue, 11 Apr 2006 10:39:08 -0700 (PDT)
Message-ID: <6b4e42d10604111039y7c2920bdr2e33cce3873da9ed@mail.gmail.com>
Date: Tue, 11 Apr 2006 10:39:08 -0700
Sender: Benjamin LaHaise <bcrl@kvack.org>
From: "Om Narasimhan" <om.turyx@gmail.com>
Subject: Re: [RFC] [PATCH] support for oom_die
In-Reply-To: <Pine.LNX.4.64.0604111025110.564@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <20060411142909.1899c4c4.kamezawa.hiroyu@jp.fujitsu.com>
	 <Pine.LNX.4.64.0604111025110.564@schroedinger.engr.sgi.com>
Return-Path: <bcrl@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> A user process can cause an oops by using too much memory? Would it not be
> better to terminate the rogue process instead? Otherwise any user can
> bring down the system?
How can we differentiate a rogue process requestion huge amount of
memory and a legitimate process requesting huge amount of memory? Or
do you mean despite the status, kill the process that request huge
amounts of memory?

Om.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
