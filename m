Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 760A66B0071
	for <linux-mm@kvack.org>; Fri, 19 Nov 2010 10:51:30 -0500 (EST)
Received: by yxt3 with SMTP id 3so3014141yxt.14
        for <linux-mm@kvack.org>; Fri, 19 Nov 2010 07:51:20 -0800 (PST)
Subject: Re: percpu: Implement this_cpu_add,sub,dec,inc_return
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <alpine.DEB.2.00.1011190941380.32655@router.home>
References: <alpine.DEB.2.00.1011091124490.9898@router.home>
	 <alpine.DEB.2.00.1011100939530.23566@router.home>
	 <1290018527.2687.108.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1011190941380.32655@router.home>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 19 Nov 2010 16:51:10 +0100
Message-ID: <1290181870.3034.136.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Le vendredi 19 novembre 2010 A  09:42 -0600, Christoph Lameter a A(C)crit :
> On Wed, 17 Nov 2010, Eric Dumazet wrote:
> 
> > diff --git a/include/linux/highmem.h b/include/linux/highmem.h
> > index b676c58..bb5db26 100644
> > --- a/include/linux/highmem.h
> > +++ b/include/linux/highmem.h
> > @@ -91,7 +91,7 @@ static inline int kmap_atomic_idx_push(void)
> >
> >  static inline int kmap_atomic_idx(void)
> >  {
> > -	return __get_cpu_var(__kmap_atomic_idx) - 1;
> > +	return __this_cpu_read(__kmap_atomic_idx) - 1;
> >  }
> >
> >  static inline int kmap_atomic_idx_pop(void)
> 
> This isnt a use case for this_cpu_dec right? Seems that your message was
> cut off?
> 


I wanted to show you the file were it was possible to use this_cpu_{dec|
inc}_return()


My patch on kmap_atomic_idx() doesnt need your new functions ;)

Thanks


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
