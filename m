Received: by zproxy.gmail.com with SMTP id k1so346395nzf
        for <linux-mm@kvack.org>; Fri, 07 Oct 2005 00:54:52 -0700 (PDT)
Message-ID: <aec7e5c30510070054u469e79a0xb7a58f3dad81609b@mail.gmail.com>
Date: Fri, 7 Oct 2005 16:54:52 +0900
From: Magnus Damm <magnus.damm@gmail.com>
Reply-To: Magnus Damm <magnus.damm@gmail.com>
Subject: Re: [PATCH] i386: srat and numaq cleanup
In-Reply-To: <1128610585.8401.15.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <20051005083846.4308.37575.sendpatchset@cherry.local>
	 <1128530262.26009.27.camel@localhost>
	 <aec7e5c30510060329kb59edagb619f00b8a58bf3e@mail.gmail.com>
	 <1128610585.8401.15.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Magnus Damm <magnus@valinux.co.jp>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On 10/6/05, Dave Hansen <haveblue@us.ibm.com> wrote:
> On Thu, 2005-10-06 at 19:29 +0900, Magnus Damm wrote:
> > On 10/6/05, Dave Hansen <haveblue@us.ibm.com> wrote:
> > > I'm highly suspicious of any "cleanup" that adds more code than it
> > > deletes.  What does this clean up?
> >
> > The patch removes #ifdefs from get_memcfg_numa() and introduces an
> > inline get_zholes_size(). The #ifdefs are moved down one level to the
> > files srat.h and numaq.h and empty inline functions are added. These
> > empty inline function are probably the reason for the added lines.
>
> It does remove two #ifdefs, but it adds two #else blocks in other
> places.
>
> I also noticed that acpi20_parse_srat() can fail.  So, has_srat may
> belong in that function, not in get_memcfg_from_srat()

Yes, that is better.

> Why ever have this block?
>
> > +       if ((ret = get_zholes_size_numaq(nid)))
> > +               return ret;
>
> get_zholes_size_numaq() is *ALWAYS* empty/false, right?  There's no need
> to have a stub for it.

That is correct. I just kept it there to make the srat and numaq code
more similar, but I'd be happy to remove it. If you still consider
this as a cleanup, please let me know and I will generate a new patch.

Thanks,

/ magnus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
