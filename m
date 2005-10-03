Received: by zproxy.gmail.com with SMTP id k1so213039nzf
        for <linux-mm@kvack.org>; Sun, 02 Oct 2005 22:59:33 -0700 (PDT)
Message-ID: <aec7e5c30510022259v46316af2wff1ee92f1ce3d288@mail.gmail.com>
Date: Mon, 3 Oct 2005 14:59:31 +0900
From: Magnus Damm <magnus.damm@gmail.com>
Reply-To: Magnus Damm <magnus.damm@gmail.com>
Subject: Re: [PATCH 00/07][RFC] i386: NUMA emulation
In-Reply-To: <20051002223352.6d21a8bc.pj@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <20050930073232.10631.63786.sendpatchset@cherry.local>
	 <1128093825.6145.26.camel@localhost>
	 <20051002202157.7b54253d.pj@sgi.com>
	 <aec7e5c30510022205o770b6335o96d9a9d9cc5d7397@mail.gmail.com>
	 <20051002223352.6d21a8bc.pj@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: haveblue@us.ibm.com, magnus@valinux.co.jp, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 10/3/05, Paul Jackson <pj@sgi.com> wrote:
> Magnus wrote:
> > So, Paul, please let me know if you prefer SMP || NUMA or no
> > depencencies in the Kconfig.
>
> In theory, I prefer none.  But the devil is in the details here,
> and I really don't care that much.
>
> So pick whichever you prefer, or whichever provides the nicest
> looking code or patch, or flip a coin ;).

I'm tempted to consult the magic eight-ball, but I think I will stick
with the advice from Takahashi-san instead. =) So, the dependency will
be removed.

/ magnus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
