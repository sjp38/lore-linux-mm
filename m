Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id B14236B004F
	for <linux-mm@kvack.org>; Tue, 27 Dec 2011 08:30:24 -0500 (EST)
Date: Tue, 27 Dec 2011 14:30:21 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm: hugetlb: add might_sleep() for gigantic page
Message-ID: <20111227133021.GI5344@tiehlicka.suse.cz>
References: <CAJd=RBCXTp0GrMGw+MBDdj0K15+L5v+O2t6EcDghFk34aNwt1g@mail.gmail.com>
 <20111227125945.GH5344@tiehlicka.suse.cz>
 <CAJd=RBA70k8pCoP26hoJua=h1DHgx7eLHU0qrukJRxwoaxB65Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJd=RBA70k8pCoP26hoJua=h1DHgx7eLHU0qrukJRxwoaxB65Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Tue 27-12-11 21:21:18, Hillf Danton wrote:
> On Tue, Dec 27, 2011 at 8:59 PM, Michal Hocko <mhocko@suse.cz> wrote:
> > On Fri 23-12-11 21:41:08, Hillf Danton wrote:
> >> From: Hillf Danton <dhillf@gmail.com>
> >> Subject: [PATCH] mm: hugetlb: add might_sleep() for gigantic page
> >>
> >> Like the case of huge page, might_sleep() is added for gigantic page, then
> >> both are treated in same way.
> >
> > Why do we need to call might_sleep here? There is cond_resched in the
> > loop...
> >
> 
> IIUC it is the reason to add... and the comment says

cond_resched calls __might_sleep so there is no reason to call
might_sleep outside the loop as well.

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
