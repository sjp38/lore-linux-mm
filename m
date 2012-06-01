Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id A39896B005C
	for <linux-mm@kvack.org>; Fri,  1 Jun 2012 05:12:43 -0400 (EDT)
Received: by ggm4 with SMTP id 4so2018737ggm.14
        for <linux-mm@kvack.org>; Fri, 01 Jun 2012 02:12:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.00.1206010204150.8697@eggly.anvils>
References: <20120530163317.GA13189@redhat.com> <20120531005739.GA4532@redhat.com>
 <20120601023107.GA19445@redhat.com> <alpine.LSU.2.00.1206010030050.8462@eggly.anvils>
 <4FC88299.1040707@gmail.com> <alpine.LSU.2.00.1206010204150.8697@eggly.anvils>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Fri, 1 Jun 2012 05:12:19 -0400
Message-ID: <CAHGf_=q-VBqtABfC7cYPFY6AtQjjwHAM+0BD-DQ2G1sYoTPKGA@mail.gmail.com>
Subject: Re: WARNING: at mm/page-writeback.c:1990 __set_page_dirty_nobuffers+0x13a/0x170()
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Dave Jones <davej@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Cong Wang <amwang@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Jun 1, 2012 at 5:08 AM, Hugh Dickins <hughd@google.com> wrote:
> On Fri, 1 Jun 2012, KOSAKI Motohiro wrote:
>> > =A0 =A0 mlock_migrate_page(newpage, page);
>> > --- 3.4.0+/mm/page-writeback.c =A0 =A0 =A02012-05-29 08:09:58.30480678=
2 -0700
>> > +++ linux/mm/page-writeback.c =A0 =A0 =A0 2012-06-01 00:23:43.98411697=
3 -0700
>> > @@ -1987,7 +1987,10 @@ int __set_page_dirty_nobuffers(struct pa
>> > =A0 =A0 =A0 =A0 =A0 =A0 mapping2 =3D page_mapping(page);
>> > =A0 =A0 =A0 =A0 =A0 =A0 if (mapping2) { /* Race with truncate? */
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 BUG_ON(mapping2 !=3D mapping);
>> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 WARN_ON_ONCE(!PagePrivate(page)&=
&
>> > !PageUptodate(page));
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (WARN_ON(!PagePrivate(page)&&
>> > !PageUptodate(page)))
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 print_symbol(KER=
N_WARNING
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "mapping=
->a_ops->writepage: %s\n",
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (unsigne=
d
>> > long)mapping->a_ops->writepage);
>>
>> type mismatch?
>
> I don't think so: I just copied from print_bad_pte().
> Probably you're reading "printk" where it's "print_symbol"?

Oops, yes, sorry for noise.


>> I guess you want %pf or %pF.
>
> I expect there is new-fangled %pMagic that can do it too, yes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
