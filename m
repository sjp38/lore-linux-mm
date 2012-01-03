Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id C74A36B0096
	for <linux-mm@kvack.org>; Tue,  3 Jan 2012 16:03:45 -0500 (EST)
Received: from compute1.internal (compute1.nyi.mail.srv.osa [10.202.2.41])
	by gateway1.nyi.mail.srv.osa (Postfix) with ESMTP id D706820B23
	for <linux-mm@kvack.org>; Tue,  3 Jan 2012 16:03:44 -0500 (EST)
Date: Tue, 3 Jan 2012 12:54:28 -0800
From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH 5/6] memcg: fix broken boolen expression
Message-ID: <20120103205428.GB17131@kroah.com>
References: <1324695619-5537-1-git-send-email-kirill@shutemov.name>
 <1324695619-5537-5-git-send-email-kirill@shutemov.name>
 <20111226153138.0376bd66.kamezawa.hiroyu@jp.fujitsu.com>
 <20111226065724.GA13459@shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111226065724.GA13459@shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, containers@lists.linux-foundation.org, Balbir Singh <bsingharora@gmail.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, stable@vger.kernel.org

On Mon, Dec 26, 2011 at 08:57:24AM +0200, Kirill A. Shutemov wrote:
> On Mon, Dec 26, 2011 at 03:31:38PM +0900, KAMEZAWA Hiroyuki wrote:
> > On Sat, 24 Dec 2011 05:00:18 +0200
> > "Kirill A. Shutemov" <kirill@shutemov.name> wrote:
> > 
> > > From: "Kirill A. Shutemov" <kirill@shutemov.name>
> > > 
> > > action != CPU_DEAD || action != CPU_DEAD_FROZEN is always true.
> > > 
> > > Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
> > 
> > maybe this should go stable..
> 
> CC stable@

<formletter>

This is not the correct way to submit patches for inclusion in the
stable kernel tree.  Please read Documentation/stable_kernel_rules.txt
for how to do this properly.

</formletter>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
