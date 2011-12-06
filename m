Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 241E36B004D
	for <linux-mm@kvack.org>; Tue,  6 Dec 2011 15:16:17 -0500 (EST)
Received: by vbbfn1 with SMTP id fn1so3468331vbb.14
        for <linux-mm@kvack.org>; Tue, 06 Dec 2011 12:16:16 -0800 (PST)
Date: Tue, 6 Dec 2011 12:16:13 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: hugetlb oops on 3.1.0-rc8-devel
In-Reply-To: <CALCETrVL3MUMh2kDPaZ6Z9Lz=eWas_dF0jwWMiF3KvNUcJKXJw@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1112061214590.28251@chino.kir.corp.google.com>
References: <CALCETrW1mpVCz2tO5roaz1r6vnno+srHR-dHA6_pkRi2qiCfdw@mail.gmail.com> <CAJd=RBDdirdNiPMVcYLNFO5Ho+pRGCfh_RRA7_re+76Ds+H0pw@mail.gmail.com> <CALCETrVL3MUMh2kDPaZ6Z9Lz=eWas_dF0jwWMiF3KvNUcJKXJw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="397155492-1995613491-1323202575=:28251"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--397155492-1995613491-1323202575=:28251
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Wed, 2 Nov 2011, Andy Lutomirski wrote:

> > --- a/mm/hugetlb.c      Sat Aug 13 11:45:14 2011
> > +++ b/mm/hugetlb.c      Wed Nov  2 20:12:00 2011
> > @@ -2422,6 +2422,8 @@ retry_avoidcopy:
> >         * anon_vma prepared.
> >         */
> >        if (unlikely(anon_vma_prepare(vma))) {
> > +               page_cache_release(new_page);
> > +               page_cache_release(old_page);
> >                /* Caller expects lock to be held */
> >                spin_lock(&mm->page_table_lock);
> >                return VM_FAULT_OOM;
> >
> 
> I'll patch it in.  My test case took over a week to hit it once, so I
> can't guarantee I'll spot it.
> 

This patch was merged and released in 3.2-rc3 as ea4039a34c4c ("hugetlb: 
release pages in the error path of hugetlb_cow()"), Andy is this issue 
fixed for you?
--397155492-1995613491-1323202575=:28251--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
