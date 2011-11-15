Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id AF6206B002D
	for <linux-mm@kvack.org>; Tue, 15 Nov 2011 08:35:58 -0500 (EST)
Received: by wyi11 with SMTP id 11so1121989wyi.14
        for <linux-mm@kvack.org>; Tue, 15 Nov 2011 05:35:55 -0800 (PST)
Message-ID: <1321364130.1944.2.camel@localhost.localdomain>
Subject: Re: khugepaged cannot be freezed on 3.2-rc1
From: Maciej Marcin Piechotka <uzytkownik2@gmail.com>
Date: Tue, 15 Nov 2011 13:35:30 +0000
In-Reply-To: <4EC0A9B3.7020201@linux.vnet.ibm.com>
References: <1321195355.2020.10.camel@localhost.localdomain>
	 <4EC0A9B3.7020201@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Linux PM mailing list <linux-pm@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Tejun Heo <tj@kernel.org>, "Rafael
 J. Wysocki" <rjw@sisk.pl>

On Mon, 2011-11-14 at 11:10 +0530, Srivatsa S. Bhat wrote:
> On 11/13/2011 08:12 PM, Maciej Marcin Piechotka wrote:
> > I am sorry if I've sent to wrong address. It seems that bug reporting
> > resources - bugzilla & "Reporting bugs for the Linux kernel" page - are
> > (still?) down. I followed the latter from web archive).
> >
> 
> Adding linux-pm mailing list to CC.
> Andrea Arcangeli has written a patch to solve khugepaged freezing issue.
> https://lkml.org/lkml/2011/11/9/312
> 
> Can you check if that patch solves the issue for you too?
> 
> Thanks,
> Srivatsa S. Bhat

Yes, it solves the problem (sorry for delay in responding).

Regards

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
