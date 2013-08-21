Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 11E0C6B0032
	for <linux-mm@kvack.org>; Wed, 21 Aug 2013 16:49:12 -0400 (EDT)
Date: Wed, 21 Aug 2013 16:49:01 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: unused swap offset / bad page map.
Message-ID: <20130821204901.GA19802@redhat.com>
References: <20130807055157.GA32278@redhat.com>
 <CAJd=RBCJv7=Qj6dPW2Ha=nq6JctnK3r7wYCAZTm=REVOZUNowg@mail.gmail.com>
 <20130807153030.GA25515@redhat.com>
 <CAJd=RBCyZU8PR7mbFUdKsWq3OH+5HccEWKMEH5u7GNHNy3esWg@mail.gmail.com>
 <20130819231836.GD14369@redhat.com>
 <CAJd=RBA-UZmSTxNX63Vni+UPZBHwP4tvzE_qp1ZaHBqcNG7Fcw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJd=RBA-UZmSTxNX63Vni+UPZBHwP4tvzE_qp1ZaHBqcNG7Fcw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>

On Tue, Aug 20, 2013 at 12:39:05PM +0800, Hillf Danton wrote:
 > On Tue, Aug 20, 2013 at 7:18 AM, Dave Jones <davej@redhat.com> wrote:
 > 
 > --- a/mm/memory.c Wed Aug  7 16:29:34 2013
 > +++ b/mm/memory.c Tue Aug 20 11:13:06 2013
 > @@ -933,8 +933,10 @@ again:
 >   if (progress >= 32) {
 >   progress = 0;
 >   if (need_resched() ||
 > -    spin_needbreak(src_ptl) || spin_needbreak(dst_ptl))
 > +    spin_needbreak(src_ptl) || spin_needbreak(dst_ptl)) {
 > +     BUG_ON(entry.val);
 >   break;
 > + }
 >   }
 >   if (pte_none(*src_pte)) {
 >   progress++;

didn't hit the bug_on, but got a bunch of 

[  424.077993] swap_free: Unused swap offset entry 000187d5
[  439.377194] swap_free: Unused swap offset entry 000187e7
[  441.998411] swap_free: Unused swap offset entry 000187ee
[  446.956551] swap_free: Unused swap offset entry 0000245f

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
