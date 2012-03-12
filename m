Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 256F36B004D
	for <linux-mm@kvack.org>; Mon, 12 Mar 2012 12:31:40 -0400 (EDT)
Date: Mon, 12 Mar 2012 11:04:05 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: ClockPro in Linux MM
In-Reply-To: <CAFLer81iFkuyQQc8M_AR9pULQDyrMYZux2s3KPK-3kGzB2XTKw@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1203121102590.6396@router.home>
References: <CAFLer81iFkuyQQc8M_AR9pULQDyrMYZux2s3KPK-3kGzB2XTKw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zheng Da <zhengda1936@gmail.com>
Cc: linux-mm@kvack.org

On Mon, 12 Mar 2012, Zheng Da wrote:

> I try to understand the Linux memory management. I was told Linux uses
> ClockPro to manage page cache
> and http://linux-mm.org/PageReplacementDesign also says so for file pages.
> But when I read the ClockPro paper,
> it doesn't look the same. The Linux implementation doesn't have
> non-resident pages. Other than
> that, it doesn't have the same test period mentioned in the paper. I wonder
> if the Linux implementation
> have the same effect as ClockPro. Could anyone confirm Linux is still using
> ClockPro?

That Linux is using Clockpro is news to me. Linux Memory management uses
some ideas from Clockpro to improve reclaim etc but it does not implement ClockPro.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
