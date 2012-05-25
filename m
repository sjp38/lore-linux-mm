Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id D1A41940001
	for <linux-mm@kvack.org>; Fri, 25 May 2012 05:30:38 -0400 (EDT)
Date: Fri, 25 May 2012 17:29:36 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [PATCH 0/2 v4] Flexible proportions
Message-ID: <20120525092936.GA12729@localhost>
References: <1337878751-22942-1-git-send-email-jack@suse.cz>
 <1337937162.9783.163.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1337937162.9783.163.camel@laptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri, May 25, 2012 at 11:12:42AM +0200, Peter Zijlstra wrote:
> On Thu, 2012-05-24 at 18:59 +0200, Jan Kara wrote:
> >   here is the next iteration of my flexible proportions code. I've addressed
> > all Peter's comments. 
> 
> Thanks, all I could come up with is comment placement nits and I'll not
> go there ;-)
> 
> Acked-by: Peter Zijlstra <a.p.zijlstra@chello.nl>

Thank you both for making it work!  I've applied them to the writeback tree.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
